#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

Hostname="mongodb.daws91.online"

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
    exit 1
    else
    echo -e "$2...$G success $N"
  fi
}

dnf module disable nodejs -y &>> $LOGFILE
validate $? "nodejs disabled"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "nodejs enabled"

dnf install nodejs -y  &>> $LOGFILE
validate $? "nodejs installed"


id roboshop
if [ $? -ne 0 ]
    then
    useradd roboshop
    validate $? "roboshop user created"
    else
    echo -e "user alreay exists $Y skipped $N"
fi

mkdir -p /app &>> $LOGFILE
validate $? "new dir created for new user"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
validate $? "app downloaded"

cd /app &>> $LOGFILE
validate $? "inside app dir"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
validate $? "unzip app inside app dir"

npm install &>> $LOGFILE
validate $? "dependencies installed"

cp /home/centos/roboshop-shell/catalogue.service   /etc/systemd/system/catalogue.service &>> $LOGFILE
validate $? "copied services"

systemctl daemon-reload &>> $LOGFILE
validate $? "reload services"

systemctl enable catalogue &>> $LOGFILE
validate $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE
validate $? "start catalogue"

cp  /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $? "cpyed mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
validate $? "installed mongo client"

mongo --host $Hostname < /app/schema/catalogue.js &>> $LOGFILE
validate $? "insered products to the mongodb"

