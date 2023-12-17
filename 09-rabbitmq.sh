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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
validate $?  "Configure YUM Repos from the script provided by vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
validate $?  "Configure YUM Repos for RabbitMQ"

dnf install rabbitmq-server -y &>> $LOGFILE
validate $? "installed rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE
validate $? "enabled rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE
validate $? "started rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
validate $? "added user & passwd"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
validate $? "set permissions"

