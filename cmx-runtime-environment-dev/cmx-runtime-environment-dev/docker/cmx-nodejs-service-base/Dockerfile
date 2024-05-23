FROM alpine

# Update/Upgrade apk and it's packages
RUN apk update; apk upgrade

# Install standard tools
RUN apk add --update \
  bash \
  git \
	gnupg \
	openssl \
  openssh \
  sudo \
	tar \
	wget; rm -rf /var/cache/apk/*

# Install Ant, Maven and OpenJDK
RUN apk add --update \
  nodejs \
  nodejs-npm; rm -rf /var/cache/apk/*

# Add directories
RUN mkdir -p /opt
RUN mkdir -p /opt/scripts
RUN mkdir -p /opt/tools
