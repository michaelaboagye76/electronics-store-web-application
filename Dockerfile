# Stage 1: Base Python environment
FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Flask app and NGINX config
COPY . .
COPY nginx.conf /etc/nginx/sites-available/default

# Expose port 80 for NGINX
EXPOSE 80

# Start both Gunicorn and NGINX
CMD service nginx start && gunicorn --bind 127.0.0.1:5000 app:app
