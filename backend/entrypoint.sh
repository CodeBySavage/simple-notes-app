#!/bin/sh
echo "Waiting for postgres..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done
echo "Postgres is up!"

python manage.py migrate --noinput
exec gunicorn backend.wsgi:application --bind 0.0.0.0:8000