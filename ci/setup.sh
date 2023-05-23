#!/usr/bin/env sh

target="$1"
if [ "$target" = "" ]; then
	target="all"
fi

if [ "$target" = "all" ]; then
    npm ci
    chmod +x ./node_modules/.bin/eslint
elif [ "$target" = "production" ]; then
    npm ci --production
fi
