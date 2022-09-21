#!/bin/bash
echo "export LC_ALL=en_US.UTF-8" >> ~/.bash_profile
echo "export LANG=en_US.UTF-8" >> ~/.bash_profile
source ~/.bash_profile

# Loads the Tags from the current instance
getInstanceTags () {
  # http://aws.amazon.com/code/1825 EC2 Instance Metadata Query Tool
  INSTANCE_ID=$(/usr/bin/ec2-metadata | grep instance-id | awk '{print $2}')

  # Describe the tags of this instance
  aws ec2 describe-tags --region ap-south-1 --filters "Name=resource-id,Values=$INSTANCE_ID"
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


export TAIGA_BACK_TAG=$(aws ecr describe-images --output json --repository-name taiga-back --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq . --raw-output)

# Execute the commands
instanceTags=$(getInstanceTags)
tags_to_env "$instanceTags"

# docker-compose -f docker-compose.prod.yml -f docker-compose-inits.prod.yml run --rm taiga-manage createsuperuser
