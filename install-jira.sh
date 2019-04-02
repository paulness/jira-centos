#!/bin/bash

set -eu

# Install wget
yum install -y wget

# Install JIRA
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.0.2-x64.bin
chmod +x atlassian-jira-software-8.0.2-x64.bin
./atlassian-jira-software-8.0.2-x64.bin -q -varfile /unattended-installs/jira/response.varfile
rm -rf /opt/atlassian/jira/.install4j/
rm -rf /atlassian-jira-software-8.0.2-x64.bin

# Install service desk to another directory
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-4.0.2-x64.bin
chmod +x atlassian-servicedesk-4.0.2-x64.bin
./atlassian-servicedesk-4.0.2-x64.bin -q -varfile /unattended-installs/servicedesk/response.varfile
rm -rf /opt/atlassian/jira/.install4j/
rm -rf /atlassian-servicedesk-4.0.2-x64.bin

# Move service desk to the JIRA folder
cp -R -n /opt/atlassian/servicedesk/* /opt/atlassian/jira/
rm -rf /opt/atlassian/servicedesk/
rm -rf /var/atlassian/application-data/servicedesk

# Change JVM max memory
sed -i -e 's/JVM_MAXIMUM_MEMORY="2048m"/JVM_MAXIMUM_MEMORY="4096m"/g' /opt/atlassian/jira/bin/setenv.sh
