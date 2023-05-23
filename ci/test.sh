#!/usr/bin/env sh

objective="$1"
if [ "$objective" = "" ]; then
	objective="all"
fi

echo "Running $objective tests..."

# Terraform formatting
if [ "$objective" = "all" ] || [ "$objective" = "terraform-lint" ]; then
	cd infrastructure
	env $(cat .env | xargs) terragrunt fmt -check || (echo "Failed terraform linting" && exit 1)
	cd ..
fi

# Audit NPM
if [ "$objective" = "all" ] || [ "$objective" = "node-audit" ]; then
	npm audit || (echo "Failed NPM Audit" && exit 1)
fi

# Node.JS Format
if [ "$objective" = "all" ] || [ "$objective" = "node-lint" ]; then
	eslint src || (echo "Failed Node.JS Linting" && exit 1)
fi
