#!/bin/bash

# Fetch the variables
. parm.txt

# function to get the current time formatted
currentTime()
{
  date +"%Y-%m-%d %H:%M:%S";
}

sudo docker service scale devops-gitlab=0
sudo docker service scale devops-gitlabdb=0

echo ---$(currentTime)---populate the volumes---
#to zip, use: sudo tar zcvf devops_gitlab_volume.tar.gz /var/nfs/volumes/devops_gitlab*
sudo tar zxvf devops_gitlab_volume.tar.gz -C /

echo ---$(currentTime)---create gitlab database service---
sudo docker service create -d \
--name devops-gitlabdb \
--mount type=volume,source=devops_gitlabdb_volume,destination=/var/lib/postgresql/data,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_gitlabdb_volume \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$GITLABDB_IMAGE


echo ---$(currentTime)---create gitlab service---
sudo docker service create -d \
--publish $GITLAB_PORT:80 \
--name devops-gitlab \
--mount type=volume,source=devops_gitlab_volume_data,destination=/var/opt/gitlab,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_gitlab_volume_data \
--mount type=volume,source=devops_gitlab_volume_config,destination=/etc/gitlab,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_gitlab_volume_config \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$GITLAB_IMAGE

sudo docker service scale devops-gitlabdb=1
sudo docker service scale devops-gitlab=1