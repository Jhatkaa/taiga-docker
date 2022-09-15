#!/bin/bash

chmod +x /home/ubuntu/taiga-docker/*.sh
cd /home/ubuntu/taiga-docker
source setup.sh
./run.prod.sh
