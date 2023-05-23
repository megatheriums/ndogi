#!/usr/bin/env sh

objective="$1"
if [ "$objective" = "" ]; then
	objective="all"
fi

# Terraform formatting
if [ "$objective" = "all" ] || [ "$objective" = "terraform-lint" ]; then
	cd infrastructure
	env $(cat .env | xargs) terragrunt fmt
	cd ..
fi

# Audit NPM
if [ "$objective" = "all" ] || [ "$objective" = "node-audit" ]; then
	npm audit fix
fi

# Node.JS Format
if [ "$objective" = "all" ] || [ "$objective" = "node-lint" ]; then
	eslint src --fix
fi
