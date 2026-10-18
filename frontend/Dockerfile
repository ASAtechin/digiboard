# Stage 1: Build the Flutter Web App
# Must satisfy the Dart SDK constraint in pubspec.yaml (^3.9.0); keep in step with CI.
FROM ghcr.io/cirruslabs/flutter:3.35.5@sha256:b200d9ead8fc5c8aab2dfdad40f0f8acb86f67be4c840b6830182be83a03f810 AS build-env

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:1.29-alpine@sha256:5616878291a2eed594aee8db4dade5878cf7edcb475e59193904b198d9b830de

# Copy built assets from previous stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
