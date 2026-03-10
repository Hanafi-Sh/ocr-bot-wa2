# Use the official Node.js 18 image based on Debian Buster or Bullseye
# We use 'slim' to keep the base image size smaller, but we must install Puppeteer dependencies manually.
FROM node:22-slim

# Install latest Chromium and other necessary libraries for Puppeteer/whatsapp-web.js
# We also install 'procps' which provides the 'df' and 'cgroup' commands used in your !ram command.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install application dependencies
# We use npm ci for a cleaner, more reliable build if you have a package-lock.json
RUN npm install

# Copy the rest of your application code into the container
COPY . .

# Tell Puppeteer to skip downloading its own Chromium, 
# and explicitly point it to the Google Chrome we just installed via apt-get.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# Expose the port your Express server uses (3000)
EXPOSE 3000

# Command to run your bot
CMD ["node", "index.js"]