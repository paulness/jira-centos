FROM centos:7

COPY unattended-installs /unattended-installs

# Install prerequirements
RUN yum install -y wget

# Install JIRA
RUN wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.0.2-x64.bin && \
  chmod +x atlassian-jira-software-8.0.2-x64.bin && \
  ./atlassian-jira-software-8.0.2-x64.bin -q -varfile /unattended-installs/jira/response.varfile && \
  rm -rf /opt/atlassian/jira/.install4j/ && \
  rm -rf /atlassian-jira-software-8.0.2-x64.bin

# Install service desk to another directory
RUN wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-4.0.2-x64.bin && \
  chmod +x atlassian-servicedesk-4.0.2-x64.bin && \
  ./atlassian-servicedesk-4.0.2-x64.bin -q -varfile /unattended-installs/servicedesk/response.varfile && \
  rm -rf /opt/atlassian/jira/.install4j/ && \
  rm -rf /atlassian-servicedesk-4.0.2-x64.bin

# Move service desk to the JIRA folder
RUN cp -R -n /opt/atlassian/servicedesk/* /opt/atlassian/jira/ && \
  rm -rf /opt/atlassian/servicedesk/ && \
  rm -rf /var/atlassian/application-data/servicedesk

# Copy plugins
COPY plugins /var/atlassian/jira/plugins/installed-plugins

EXPOSE 8080

# Run JIRA service
ENTRYPOINT ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
