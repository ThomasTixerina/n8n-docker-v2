FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies for building native modules
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy built application (dist folder should exist from local build)
COPY dist ./dist

# Copy .env file if exists (for local testing)
COPY .env* ./

# Expose orchestrator port
EXPOSE 3000

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/dashboard/status', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

# Set environment to production
ENV NODE_ENV=production

# Start the orchestrator
CMD ["node", "dist/main.js"]
