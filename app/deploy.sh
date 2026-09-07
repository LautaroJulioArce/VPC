#!/bin/bash
set -e
git pull
sudo docker build -t vpc-web .
sudo docker stop vpc-web-container
sudo docker rm vpc-web-container
sudo docker run -d --name vpc-web-container -p 80:80 vpc-web