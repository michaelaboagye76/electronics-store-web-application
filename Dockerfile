# Use official Python 3.12 image
FROM python:3.12-slim

# Install Nginx and bash
RUN apt-get update && apt-get install -y nginx bash && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy app code
COPY . /app/

# Copy Nginx config
COPY default.conf /etc/nginx/sites-enabled/default

# Expose HTTP port
EXPOSE 80

# Start Flask app and Nginx
CMD ["bash", "-c", "python app.py & nginx -g 'daemon off;'"]
