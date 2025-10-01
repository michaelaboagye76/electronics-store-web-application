# Use Python base image
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Copy dependency file
COPY requirements.txt requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose Flask port
EXPOSE 5000

# Run Flask
CMD ["python", "app:app.py"]
