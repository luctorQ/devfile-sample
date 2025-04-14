# Install the app dependencies in a full Node docker image
FROM node:18 AS build

WORKDIR /usr/src/app
# Copy package.json, and optionally package-lock.json if it exists
COPY package.json package-lock.json* ./

# Install app dependencies
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  else npm install; \
  fi

# Copy the dependencies into a Slim Node docker image
FROM node:18-alpine

RUN apk update
RUN apk add git
RUN apk add curl
RUN apk add net-tools
RUN apk add busybox-extras

RUN addgroup -S appgroup && adduser -S appuser -G appgroup -h /home/appuser

USER appuser
WORKDIR /home/appuser

# Install app dependencies
COPY --from=build /usr/src/app/node_modules /home/appuser/node_modules
COPY . /home/appuser

ENV NODE_ENV production
ENV PORT 3001

CMD ["npm", "start"]
