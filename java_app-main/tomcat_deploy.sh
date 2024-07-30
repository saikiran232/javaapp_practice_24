#!/bin/bash

echo "TOMCAT_URL: $TOMCAT_URL"
echo "CONTEXT_PATH: $CONTEXT_PATH"
curl -s -u $1:$2 $3/manager/text/list | grep "$4"
check_app=$(curl -s -u $1:$2 $3/manager/text/list | grep $4)

if [[ -n "$check_app" ]]; then
	echo "Application already exists, undeploy it first"
	curl -s -u $1:$2 $3/manager/text/undeploy?path=$4
	echo "Undeployed existing application."
fi

echo "Deploying application to Tomcat."
curl -s -u $1:$2 -T calculator_app/target/calculator.war $3/manager/text/deploy?path=$4 
