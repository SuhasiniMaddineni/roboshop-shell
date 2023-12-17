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
    exit 1
    else
    echo -e "$2...$G success $N"
  fi
}

dnf install python36 gcc python3-devel -y &>> $LOGFILE

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
    then
    useradd roboshop
    validate $? "roboshop user created"
    else
    echo -e "user alreay exists $Y skipped $N"
fi

mkdir -p /app &>> $LOGFILE
validate $? "new dir created for new user"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
validate $? " downloaded payment ziped file"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
validate $?  "unzipped file"
pip3.6 install -r requirements.txt &>> $LOGFILE
validate $?  "installed extra dependencies"
cp /home/centos/roboshop-shell/payment.service  /etc/systemd/system/payment.service &>> $LOGFILE
validate $?  "created service"
systemctl daemon-reload &>> $LOGFILE
validate $?  "reload service"
systemctl enable payment  &>> $LOGFILE
validate $?  "enabled  payment"
systemctl start payment &>> $LOGFILE
validate $?  "started payment"