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

dnf install nginx -y &>> $LOGFILE
validate $? "installed nginx"

systemctl enable nginx &>> $LOGFILE
validate $? "enabled nginx"

systemctl start nginx &>> $LOGFILE
validate $? "started nginx"

rm -rf /usr/share/nginx/html/* 
validate $? "removed existing html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
validate $? "downloaded web zipped content"

cd /usr/share/nginx/html 

unzip /tmp/web.zip &>> $LOGFILE
validate $? "unziped web"

cp /home/centos/roboshop-shell/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
validate $? "roboshop configured"

systemctl restart nginx &>> $LOGFILE
validate $? "restarted nginx"

