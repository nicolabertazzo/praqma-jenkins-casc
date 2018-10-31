FROM praqma/jenkins4casc:latest
COPY plugins_extra.txt /usr/share/jenkins/ref/plugins_extra.txt

LABEL maintainer="man@praqma.net" 

ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.CLI.disabled=true ${JAVA_OPTS:-}"
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins_extra.txt


