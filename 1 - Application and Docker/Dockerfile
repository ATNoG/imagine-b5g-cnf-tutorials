FROM python:3.12

# Update the packages
RUN apt-get update && apt-get install -y

# Copy the needed files
RUN mkdir -p /app
COPY main.py /app
COPY requirements.txt /app

# Change current directory
WORKDIR /app

# Install requirements
RUN pip install -r requirements.txt

# Expose the port to other containers
EXPOSE 8000

# Run the app
CMD ["fastapi", "run", "main.py", "--port", "8000"]
