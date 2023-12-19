#!/bin/bash


AMI=ami-03265a0778a880afb
SG_ID=sg-0ab4941a3f9f404b7

INSTANCES=("mongodb" "mysql" "shipping" "redis" "rabbitmq" "user" "cart" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
       INSTANCE_TYPE="t3.small"
    else
       INSTANCE_TYPE="t2.micro"
    fi 

    aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE 
    --security-group-ids sg-0ab4941a3f9f404b7 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"

done

