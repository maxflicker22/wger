#!/bin/bash

# Warte darauf, dass die Datenbank bereit ist
echo "Warte auf Datenbank..."
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 0.1
done

# Migrations & statische Dateien
python manage.py migrate
python manage.py collectstatic --noinput

# Superuser automatisch erstellen (nur falls nicht vorhanden)
echo "Erstelle Superuser..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="admin").exists():
    User.objects.create_superuser("admin", "markus.flicker@gmail.com", "DidPvA!1")
END

# Start der App
echo "Starte Gunicorn..."
gunicorn wger.wsgi:application --bind 0.0.0.0:8000
