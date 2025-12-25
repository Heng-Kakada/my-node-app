# --- Stage 1: Build & Dependencies ---
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install ALL dependencies (including devDependencies for testing/building)
RUN npm install

# Copy the rest of your source code
COPY . .

# (Optional) If you had a build step (like TypeScript), you'd run it here:
# RUN npm run build

# Remove development dependencies to keep the final image lean
RUN npm prune --production


# --- Stage 2: Final Runtime ---
FROM node:20-alpine

# Set environment to production
ENV NODE_ENV=production
WORKDIR /app

# Install curl for the Docker Healthcheck (standard in enterprise environments)
RUN apk add --no-cache curl

# Create a non-root user for security
# Big companies never run containers as 'root'
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/app.js ./app.js
COPY --from=builder /app/package.json ./package.json

# Switch to the non-root user
USER appuser

# Expose the internal port
EXPOSE 3000

# Healthcheck instruction: Docker will check this every 30s
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "app.js"]