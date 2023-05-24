#!/usr/bin/env bash

cd infrastructure
env $(cat ../.env | xargs) terragrunt plan
