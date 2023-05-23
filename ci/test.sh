#!/usr/bin/env sh

objective="$1"
if [ "$objective" = "" ]; then
	objective="all"
fi

echo "Running $objective tests..."

# Terraform formatting
if [ "$objective" = "all" ] || [ "$objective" = "terraform-lint" ]; then
	cd infrastructure
	env $(cat .env | xargs) terragrunt fmt -check
    exit_code=$?
    if [ exit_code != 0 ]; then
        echo "Failed terraform linting"
        exit $exit_code
    fi
	cd ..
fi

# Audit NPM
if [ "$objective" = "all" ] || [ "$objective" = "node-audit" ]; then
	npm audit
    exit_code=$?
    if [ exit_code != 0 ]; then
        echo "Failed NPM Audit"
        exit $exit_code
    fi
fi

# Node.JS Format
if [ "$objective" = "all" ] || [ "$objective" = "node-lint" ]; then
	./node_modules/.bin/eslint src
    exit_code=$?
    if [ $exit_code != 0 ]; then
        echo "Failed Node.JS Linting"
        exit $exit_code
    fi
fi
