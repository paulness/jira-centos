FROM centos:7

# Copy scripts
COPY unattended-installs /unattended-installs
COPY install-jira.sh /install-jira.sh

# Install JIRA/ServiceDesk
RUN ./install-jira.sh

# Copy plugins to Jira user folder
COPY plugins /var/atlassian/jira/plugins/installed-plugins

# Run JIRA service
EXPOSE 8080
ENTRYPOINT ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
