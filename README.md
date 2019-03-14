# jira-centos

JIRA Server 8.0.2 interactive installation instructions on CentOS 7 VM.

## Optional prerequirements

### Create the cloud SQL postgres database

```
CREATE DATABASE jiradb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE jiradb TO atlassianusr
```
[More on this here](https://confluence.atlassian.com/doc/database-setup-for-postgresql-173244522.html)

### Format and mount external drive (TODO)

https://www.techotopia.com/index.php/Adding_a_New_Disk_Drive_to_a_CentOS_System

```bash
fdisk /dev/sdb
p
n
p
1
defaults
defaults
w
```

### Mount JIRA volume (TODO)

```
mkdir -p /atlassian/jira/
mount -v -o remount,rw -force /dev/sdb1 /atlassian/jira
```

### Grant access to entire volume to JIRA user (TODO)

```
chown -R daemon:daemon /atlassian/jira/
```

### Enable IP of JIRA to access Cloud Postgres SQL (TODO)

## Install JIRA from the user folder (Interactive CLI)

```
sudo su
yum install wget
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.0.2-x64.bin
chmod +x atlassian-jira-software-8.0.2-x64.bin
./atlassian-jira-software-8.0.2-x64.bin

# Option 2 custom
```

### Route all general port 80 traffic to port 8080

```
iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 8080 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
```

### Test site on HTTP

## SSL Configuration

### Route all 443 traffic to 8443

```
iptables -A INPUT -i eth0 -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 8443 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8443
```

### Upload and move your certficate

```
mv /home/paulness/your_pfx_certificate /opt/atlassian/jira/conf/your_pfx_certificate.pfx
```

### Replace the default 8080 connector in `server.xml` with
```xml
<Connector port="8443" relaxedPathChars="[]|" relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;"
                   maxThreads="150" minSpareThreads="25" connectionTimeout="20000" enableLookups="false"
                   maxHttpHeaderSize="8192" protocol="HTTP/1.1" useBodyEncodingForURI="true"
                   acceptCount="100" disableUploadTimeout="true" bindOnInit="false"
                   secure="true" scheme="https" SSLEnabled="true" clientAuth="false"
                   keystoreFile="/opt/atlassian/jira/conf/your_pfx_certificate.pfx"
                   keystorePass="<YOUR OWN CERTIFICATE PASSWORD!>"
                   keystoreType="PKCS12"/>
```

## Configuring OKTA

Create the JIRA server app in OKTA admin and follow the instrutions in the `Sign On` tab / `SAML 2.0` Link. Overview of instructions below.

You should back up these files first

```bash
/opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml
/opt/atlassian/jira/atlassian-jira/WEB-INF/web.xml
```

Perform OKTA integration steps

```bash
# New file
vi /opt/atlassian/jira/atlassian-jira/WEB-INF/okta-config-jira.xml

# Edit
vi /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml

# Pay attention to this second edit where you add a file reference to /opt/atlassian/jira/atlassian-jira/WEB-INF/okta-config-jira.xml
vi /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml

# New file
vi /opt/atlassian/jira/atlassian-jira/okta_login.jsp

# Edit
vi /opt/atlassian/jira/atlassian-jira/WEB-INF/web.xml

# Download .jar file required for OKTA
cd /opt/atlassian/jira/atlassian-jira/WEB-INF/lib
wget https://artnet-admin.okta.com/static/toolkits/okta-jira-3.0.7.jar
```

You should ensure these files are saved / persisted on reboot of the server
```
/opt/atlassian/jira/atlassian-jira/WEB-INF/okta-config-jira.xml
/opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml
/opt/atlassian/jira/atlassian-jira/WEB-INF/web.xml
/opt/atlassian/jira/atlassian-jira/okta_login.jsp
/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/okta-jira-3.0.7.jar
```

### Restart jira
```
/opt/atlassian/jira/bin/stop-jira.sh
/opt/atlassian/jira/bin/start-jira.sh
```

## Appendix

https://confluence.atlassian.com/jirakb/how-do-i-use-port-80-or-443-on-my-jira-server-as-a-non-root-user-on-linux-890079490.html

https://confluence.atlassian.com/adminjiraserver071/unattended-installation-855475683.html

https://confluence.atlassian.com/confkb/how-to-clear-confluence-plugins-cache-297664846.html
