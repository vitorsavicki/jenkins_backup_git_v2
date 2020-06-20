FROM node as nodejs
FROM jenkins/jenkins:latest
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/node
USER root
RUN curl -sSL https://get.docker.com/ | sh
RUN apt-get update && apt-get install -y make git openjdk-8-jdk maven sudo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers \
      && printf '#!/bin/bash\nsudo /usr/bin/docker "$@"' > /usr/local/bin/docker \
      && chmod +x /usr/local/bin/docker
RUN mkdir /srv/backup && chown jenkins:jenkins /srv/backup
RUN curl https://cli-assets.heroku.com/install-ubuntu.sh | sh && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN echo latest > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo latest > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JENKINS_URL http://localhost:8080
COPY --chown=jenkins:jenkins config_jenkins /var/jenkins_home