#! /bin/sh

# template the logging configuration
defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
envsubst "$defined_envs" < "/app/logging.ini.template" > "/app/carlhauser_server/logging.ini"
envsubst "$defined_envs" < "/app/logging.ini.template" > "/app/carlhauser_client/logging.ini"

cd /app/carlhauser_server/

python ./instance_handler.py
