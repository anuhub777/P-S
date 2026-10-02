# Stage 1: Build Frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Run Unified Server
FROM node:22-alpine
# Install native build tools for node-pty and bash
RUN apk add --no-cache python3 make g++ linux-headers bash

WORKDIR /app

# Copy backend dependencies and install production packages
COPY backend/package*.json ./backend/
RUN cd backend && npm install --production

# Copy backend source
COPY backend/src ./backend/src

# Copy built frontend dist
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Create persistent storage directories
RUN mkdir -p /app/backend/data /app/backend/workspace

WORKDIR /app/backend

# Default port
ENV PORT=3001
ENV NODE_ENV=production

EXPOSE 3001

CMD ["node", "src/server.js"]
