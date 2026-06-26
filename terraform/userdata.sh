#!/bin/bash

set -e

dnf update -y

#############################################
# Install Node.js 22
#############################################

curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -

dnf install -y nodejs

#############################################
# Install Nginx
#############################################

dnf install -y nginx

systemctl enable nginx
systemctl start nginx

#############################################
# Install unzip
#############################################

dnf install -y unzip

#############################################
# Create deployment directory
#############################################

mkdir -p /opt/react-cicd-demo

chown ec2-user:ec2-user /opt/react-cicd-demo

#############################################
# SSM Agent
#############################################

dnf install -y amazon-ssm-agent || true

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent
