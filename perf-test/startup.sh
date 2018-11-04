#!/bin/sh

echo "START STARTUP LOG $(date)"

echo "I am: $(whoami)"
echo "PWD: $(pwd)"
echo "\nEnv Vars: $(env)\n"

uwsgi --ini /app/flask_k8_test_app.ini &
service nginx restart

tail -f /dev/null