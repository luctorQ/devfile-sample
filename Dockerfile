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

WORKDIR /usr/src/app

# Install app dependencies
COPY --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY . /usr/src/app

ENV NODE_ENV production
ENV PORT 3001

CMD ["npm", "start"]
