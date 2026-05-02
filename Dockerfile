# Build stage
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Post-build: rename _app → app and patch paths
WORKDIR /app/build
RUN if [ -d "_app" ]; then \
    mv _app app \&& \
    sed -i 's|/_app/|/app/|g' index.html \&& \
    find app -name "*.js" -exec sed -i 's|/_app/|/app/|g' {} +; \
fi
RUN touch .nojekyll

# Serve stage
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
