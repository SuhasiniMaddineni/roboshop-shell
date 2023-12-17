#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

Hostname="mysql.daws91.online"
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

dnf install maven -y &>> $LOGFILE
validate $? "installed maven"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
validate $? "download shipping s/w"


cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE
validate $? "unzip code to app dir "

mvn clean package &>> $LOGFILE
validate $? "installed extra dependencyes"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
validate $? "moved jar file"

cp /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE
validate $? "copied services"

systemctl daemon-reload &>> $LOGFILE
validate $? "reloaded services"

systemctl enable shipping &>> $LOGFILE
validate $? "enable shipping"

systemctl start shipping &>> $LOGFILE
validate $? "startd shipping"

dnf install mysql -y &>> $LOGFILE
validate $? "installed mysql"

mysql -h $Hostname -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
validate $? "connected to mysql"

systemctl restart shipping  &>> $LOGFILE
validate $? "restarted shipping"