FROM praqma/jenkins4casc:latest
COPY plugins_extra.txt /usr/share/jenkins/ref/plugins_extra.txt

LABEL maintainer="man@praqma.net" 

ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.CLI.disabled=true ${JAVA_OPTS:-}"

# If running behind a corporate proxy, correct proxy settings will need to be in place before the install-plugins script run.
# Set the following environment variables with the correct address and port and it will be picked up by the script
# ENV HTTP_PROXY your.company.proxy:80
# ENV HTTPS_PROXY your.company.proxy:80
# RUN export http_proxy=$HTTP_PROXY
# RUN export https_proxy=$HTTPS_PROXY
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins_extra.txt


