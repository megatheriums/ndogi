#!/usr/bin/env bash

if [ ! -f /usr/local/aws-cli/v2/current/bin/aws ]; then
	# TODO Update AWS CLI
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -oq awscliv2.zip
	sudo ./aws/install
	rm awscliv2.zip
	rm -rf aws
fi
