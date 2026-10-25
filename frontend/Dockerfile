# Stage 1: Build the Flutter Web App
# Must satisfy the Dart SDK constraint in pubspec.yaml (^3.9.0); keep in step with CI.
FROM ghcr.io/cirruslabs/flutter:3.44.0@sha256:46691e311715845de03a3ba4753a475476936805b29431b1f00f1816981033f8 AS build-env

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
# Engine files from this site, not a CDN, so the installed web app starts offline.
RUN flutter build web --release --no-web-resources-cdn

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
