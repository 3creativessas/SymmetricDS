FROM ubuntu:16.04

MAINTAINER Andres Rodriguez <ar@3creatives.com.co>

# Instala JAVA
#RUN apt-get install -y software-properties-common
RUN apt-get update -y
RUN apt-get install -y software-properties-common
#RUN add-apt-repository -y ppa:webupd8team/java
#RUN apt-get update -y
#RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections &&   apt-get update &&   apt-get install -y software-properties-common &&  add-apt-repository -y ppa:webupd8team/java &&   apt-get update &&   apt-get install -y oracle-java8-installer  &&   rm -rf /var/lib/apt/lists/* &&   rm -rf /var/cache/oracle-jdk8-installer


RUN add-apt-repository ppa:webupd8team/java \
# accept oracle license
  && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
  && apt-get update \
# install oracle jdk 8 and make it default
  && apt-get -y install oracle-java8-installer \
  && apt-get -y install oracle-java8-set-default \
# clean up
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/*



RUN apt-get install -y unzip
RUN apt-get install -y wget

RUN wget -O sym.zip https://sourceforge.net/projects/symmetricds/files/symmetricds/symmetricds-3.10/symmetric-server-3.10.3.zip/download
RUN unzip sym.zip
RUN rm sym.zip

COPY docker-entrypoint.sh docker-entrypoint.sh
COPY samples/* /sym/samples

ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT ["./docker-entrypoint.sh"]

RUN ["chmod", "+x", "/docker-entrypoint.sh"]

