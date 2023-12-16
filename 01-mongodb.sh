#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started execution at: $TIMESTAMP" &>> $LOGFILE

if [ $ID -ne 0 ]
    then
    echo -e "$R Error: yur not root user $N"
    exit 1
    else
    echo -e "$G your in root user $N"
fi


validate(){
  if [ $1 -ne 0 ]
    then
    echo -e "$2... $R failed $N"
    else
    echo -e "$2...$G success $N"
  fi
}

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $?  "copyed mongodb repo"

dnf install mongodb-org -y  &>> $LOGFILE
validate $?  "install mongodb suceess"

systemctl enable mongod  &>> $LOGFILE
validate $?  "enable mongodb"

systemctl start mongod &>> $LOGFILE
validate $?  "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf  &>> $LOGFILE
validate $?  "changed IP address to remote"

systemctl restart mongod &>> $LOGFILE
validate $?  "restart mongodb"


