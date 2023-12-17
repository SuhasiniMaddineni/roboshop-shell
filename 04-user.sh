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
validate $? "nodejs module disabled"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "enabled nodejs new version"

dnf install nodejs -y &>> $LOGFILE
validate $? "finally installed nodejs"


id roboshop  # if not there then it is failed
if [ $? -ne 0 ]
then
    useradd roboshop 
    validate $?  "user added"
else
    echo -e "already created user $Y skipped $N"
fi 

mkdir -p /app &>> $LOGFILE
validate $? "created app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
validate $? "downloaded zipped file"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE
validate $? "unzipped in app dir"

npm install &>> $LOGFILE
validate $? "installed dependencyes"

cp /home/centos/roboshop-shell/user.service  /etc/systemd/system/user.service &>> $LOGFILE
validate $? "copied user services"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloadd service"

systemctl enable user &>> $LOGFILE
validate $? "enabled user"

systemctl start user  &>> $LOGFILE
validate $? "started user"

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
validate $? "created mongo repo"

dnf install mongodb-org-shell -y  &>> $LOGFILE
validate $? "installed mongo client server"

mongo --host $Hostname </app/schema/user.js  &>> $LOGFILE
validate $? "connected to mongo and pull the usrs data"



