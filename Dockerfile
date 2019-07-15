#FROM ubuntu:16.04
FROM picoded/ubuntu-base

MAINTAINER Andres Rodriguez <ar@3creatives.com.co>


# This is in accordance to : https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	
# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN apt-get update
RUN apt-get -y install curl

RUN apt-get install -y unzip
RUN apt-get install -y wget

RUN wget -O sym.zip https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.10/symmetric-server-3.10.3.zip/download
RUN unzip sym.zip
RUN rm sym.zip

RUN mv symmetric-server-3.10.3 sym

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY samples/* /workspace/sym/samples

ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT ["./docker-entrypoint.sh"]

RUN ["chmod", "+x", "/docker-entrypoint.sh"]

