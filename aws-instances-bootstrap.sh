#!/bin/sh
# Configures an Amazon Linux instance with some basic services out-of-box. It includes:
#  - Logs will be automatically sent to CloudWatch Logs
#  - Pre-configured with Python, Ruby and Java runtime environment
#  - CodeDeploy agent up and running expecting for deployment tasks
#  - Loads parameters configured on SSM Parameter Store as ENV VARs (/opt/env-vars.sh)
#  - Pre-configured Supervisord application named 'application'.

# VARIABLES
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
URL_CODE_DEPLOY=https://aws-codedeploy-${region}.s3.amazonaws.com/latest/codedeploy-agent.noarch.rpm
URL_CORRETTO=https://d1f2yzg3dx5xke.cloudfront.net/java-1.8.0-amazon-corretto-1.8.0_202.b08-1.amzn2.x86_64.rpm

# MAIN
mkdir -p /opt

# Configuring Swap Files
dd if=/dev/zero of=/swapfile bs=1M count=1000
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

# Installing base packages
yum update -y
yum install -y ruby python-pip

# Setting up CodeDeploy agent
curl $URL_CODE_DEPLOY --output codedeploy-agent.noarch.rpm
yum install -y codedeploy-agent.noarch.rpm
service codedeploy-agent start

# Setting up Chamber
curl \
    -o /bin/chamber \
    -LOs https://github.com/segmentio/chamber/releases/download/v2.3.3/chamber-v2.3.3-linux-amd64

chmod +x /bin/chamber
chamber export --format dotenv global | sed 's/\(.*\)/export \1/;s/\\\!/\!/g' > /opt/env-vars.sh
chamber export --format dotenv ${cannonical_name} | sed 's/\(.*\)/export \1/;s/\\\!/\!/g' >> /opt/env-vars.sh
. /opt/env-vars.sh

# Setting up CloudWatch Agent
yum install -y awslogs

sed -i -e 's/us-east-1/${region}/g' /etc/awslogs/awscli.conf

cat <<EOF > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state
use_gzip_http_content_encoding = true

[/var/log/messages]
log_group_name = ${cannonical_name}
log_stream_name = /var/log/messages.{instance_id}
file = /var/log/messages
datetime_format = %Y-%m-%d %H:%M:%S
buffer_duration = 5000
initial_position = start_of_file

[/opt/application/server.log]
log_group_name = ${cannonical_name}
log_stream_name = /ec2/opt/application/server.log.{instance_id}
file = /opt/application/server.log
datetime_format = %Y-%m-%d %H:%M:%S
initial_position = start_of_file
time_zone = UTC
encoding = utf_8
buffer_duration = 5000
EOF

systemctl start awslogsd
systemctl enable awslogsd.service

# Setting up Supervisord
pip install supervisor

cat <<EOF > /etc/supervisord.conf
[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[supervisord]
logfile=/var/log/supervisord.log
user=root

[program:application]
command=/opt/application/${app_name}.sh
directory=/opt/application
autostart=false
autorestart=false
stopsignal=TERM
stopwaitsecs=15
stdout_logfile=/var/log/application.log
redirect_stderr=true
logfile_maxbytes=100MB
logfile_backups=10

EOF

supervisord -c /etc/supervisord.conf

# NodeJS 8.X.X
curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
yum -y install nodejs

# Installing AWS Corretto JRE 8
curl $URL_CORRETTO -o java8.rpm
yum install -y java8.rpm

# Custom Script
${custom_script}
