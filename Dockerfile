FROM nginx:alpine

# Copy your static site into NGINX default web root
COPY app/ /usr/share/nginx/html/

# Expose port 80 (documentation only; runtime uses -p)
EXPOSE 80
