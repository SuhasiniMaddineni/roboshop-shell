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

dnf module disable mysql -y &>> $LOGFILE
validate $? "disabled mysql"
cp  /home/centos/roboshop-shell/mysql.repo  /etc/yum.repos.d/mysql.repo &>> $LOGFILE
validate $?  "copied mysql repo"
dnf install mysql-community-server -y &>> $LOGFILE
validate $?  "installed mysql"
systemctl enable mysqld &>> $LOGFILE
validate $?  "enabled mysql"
systemctl start mysqld &>> $LOGFILE
validate $?  "started mysql"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
validate $?  "set the passwrd"
