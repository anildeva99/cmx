FROM alpine

ENV OPENJDK_VERSION 8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre

# Update/Upgrade apk and it's packages
RUN apk update; apk upgrade

# Install standard tools
RUN apk add --update \
  bash \
  curl \
	gnupg \
	openssl \
  perl \
  sudo \
	tar \
	wget; rm -rf /var/cache/apk/*

# Install Ant, Maven and OpenJDK
RUN apk add --update \
  apache-ant \
  maven \
	openjdk${OPENJDK_VERSION}; rm -rf /var/cache/apk/*

# Add users
RUN mkdir -p /opt
RUN mkdir -p /opt/util
RUN mkdir -p /opt/scripts

# Add entrypoint script
ADD scripts/build-projects.sh /opt/scripts/build-projects.sh

# Add New Relic for profiling
ADD files/newrelic-java.zip /opt/util/newrelic-java.zip
WORKDIR /opt/util
RUN unzip newrelic-java.zip 

# Add Honest Profiler for profiling
ADD files/honest-profiler.zip /opt/util/honest-profiler/honest-profiler.zip
WORKDIR /opt/util/honest-profiler
RUN unzip honest-profiler.zip 

WORKDIR /opt/scripts
ENTRYPOINT ["./build-projects.sh"]
