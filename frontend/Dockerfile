# Stage 1: Build the Flutter Web App
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build-env

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
RUN flutter build web --release --web-renderer html

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine

# Copy built assets from previous stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
