# Use the official NGINX base image
FROM nginx:latest

# Copy the static website files to the default NGINX public directory
COPY ./static-website /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
