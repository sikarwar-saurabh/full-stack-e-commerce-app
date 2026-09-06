# stage 1: build stage

FROM node:18-alpine AS builder

#labels
 
LABEL author = "Saurabh"  project = "E-commerce"  build_date = "06-09-2025"

# build system dependencies

RUN apk add --no-cache python3 make g++

# set working directory

WORKDIR /app

# copy dependency files

COPY package*.json ./

# install dependencies

RUN npm ci

# copy application source code

COPY . .

# Build the Next.js application

RUN npm run build


# stage 2: production Stage

FROM node:18-alpine AS runner

# set working directory

WORKDIR /app

# create non-root user , group and add user to the group
 
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# copy necessary files from builder stage

# copy stanalone application
COPY --from=builder /app/.next/standalone ./

# copy static files 
COPY --from=builder /app/.next/static ./.next/static

# copy public files 

COPY --from=builder /app/public ./public

# set environment variables

ENV NODE_ENV=production
ENV PORT=3000

# expose port application runs on

EXPOSE 3000

# run application as non-root user

USER appuser

# command to run the application

CMD ["node", "server.js"]

