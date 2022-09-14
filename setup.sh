#!/bin/sh
echo "export LC_ALL=en_US.UTF-8" >> ~/.bash_profile
echo "export LANG=en_US.UTF-8" >> ~/.bash_profile
source ~/.bash_profile
sudo apt install -y awscli jq wget
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata

# Loads the Tags from the current instance
getInstanceTags () {
  # http://aws.amazon.com/code/1825 EC2 Instance Metadata Query Tool
  INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk '{print $2}')

  # Describe the tags of this instance
  aws ec2 describe-tags --region sa-east-1 --filters "Name=resource-id,Values=$INSTANCE_ID"
}

# Convert the tags to environment variables.
# Based on https://github.com/berpj/ec2-tags-env/pull/1
tags_to_env () {
    tags=$1

    for key in $(echo $tags | /usr/bin/jq -r ".[][].Key"); do
        value=$(echo $tags | /usr/bin/jq -r ".[][] | select(.Key==\"$key\") | .Value")
        key=$(echo $key | /usr/bin/tr '-' '_' | /usr/bin/tr '[:lower:]' '[:upper:]')
        echo "Exporting $key=$value"
        export $key="$value"
    done
}

# Execute the commands
instanceTags=$(getInstanceTags)
tags_to_env "$instanceTags"

# sudo apt install -y docker
# sudo curl -L "https://github.com/docker/compose/releases/download/2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
# docker-compose -f docker-compose.prod.yml -f docker-compose-inits.prod.yml run --rm taiga-manage createsuperuser
