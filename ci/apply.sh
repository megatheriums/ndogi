#!/usr/bin/env sh

cd infrastructure
env $(cat .env | xargs) terragrunt apply -auto-approve
