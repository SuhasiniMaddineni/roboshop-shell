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


dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
validate $?  "downloaded redis"


dnf module enable redis:remi-6.2 -y &>> $LOGFILE
validate $?  "enabled redis"

dnf install redis -y &>> $LOGFILE
validate $?  "installed redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf  &>> $LOGFILE
validate $?  "changed to remote access"

systemctl enable redis  &>> $LOGFILE
validate $?  "enabled redis"

systemctl start redis  &>> $LOGFILE
validate $?  "started redis"