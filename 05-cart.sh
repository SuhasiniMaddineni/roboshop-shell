#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

Host_Name="mongodb.daws91.online"

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
validate $? "disabled nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "enabled nodejs"

dnf install nodejs -y  &>> $LOGFILE
validate $? "install nodejs"

id roboshop  # if not there then it is failed
if [ $? -ne 0 ]
    then
    useradd roboshop 
    validate $? "user added"
    else
    echo "already created user $Y skipped $N"
fi 

mkdir -p /app  &>> $LOGFILE
validate $? "created app dir"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGFILE
validate $? "download zipped file"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE
validate $? "unzipped inside app dir"

npm install  &>> $LOGFILE
validate $? "installed dependencyes"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloaded services"

systemctl enable cart &>> $LOGFILE
validate $? "enabled cart"

systemctl start cart &>> $LOGFILE
validate $? "started cart"



