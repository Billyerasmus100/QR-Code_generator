# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with timeout and progress tracking
RUN npm config set fetch-retry-maxtimeout 60000 && \
    npm config set fetch-retry-mintimeout 10000 && \
    npm install --verbose --no-audit --no-fund

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage  
FROM node:18-alpine

WORKDIR /app

# Install serve with timeout settings
RUN npm config set fetch-retry-maxtimeout 60000 && \
    npm install -g serve --no-audit --no-fund

# Copy built files from build stage
COPY --from=build /app/build ./build

# Expose port
EXPOSE 3000

# Start the app
CMD ["serve", "-s", "build", "-l", "3000"]
