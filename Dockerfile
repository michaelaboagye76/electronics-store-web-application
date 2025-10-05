# Use Amazon’s public ECR Python base image
FROM public.ecr.aws/docker/library/python:3.11-slim

WORKDIR /app

# Copy dependencies first (for better build caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY . .

# Expose Flask port (will be mapped by Nginx or ECS)
EXPOSE 80

# Start Gunicorn (production WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:80", "app:app"]
