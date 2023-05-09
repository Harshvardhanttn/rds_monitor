#!/bin/bash
# Install Grafana
sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

sudo yum update
sudo yum install -y grafana

# Start Grafana
sudo systemctl start grafana-server

# Enable Grafana to start at boot time
sudo systemctl enable grafana-server

# Download and set up the default dashboard
sudo wget -O /usr/share/grafana/public/dashboards/default.json https://raw.githubusercontent.com/grafana/grafana/master/public/dashboards/default.json

# Restart Grafana to load the default dashboard
sudo systemctl restart grafana-server

echo "Grafana has been installed and configured with the default dashboard!"

cat << EOF | sudo tee /etc/grafana/provisioning/datasources/datasource.yml
apiVersion: 1
datasources:
- name: CloudWatch
  type: cloudwatch
  access: proxy
  url: https://cloudwatch.ap-northeast-1.amazonaws.com
  jsonData:
    authType: default
    defaultRegion: ap-northeast-1
    assumeRoleArn: ""
    customMetricsNamespaces: "custom-namespace-1,custom-namespace-2"
    authProxyURL: ""
    awsEndpointURL: ""
    tlsSkipVerify: false
    logsMaxResults: 1000
    logsBatchSize: 1000
    logsScanFrequency: 300s
    logsFrom: 7d
    logQueriesPerPage: 20


EOF

sudo yum install git -y

cd /home/ec2-user

su ec2-user -c "git clone https://github.com/harvar31/Monitoring.git"

cp /home/ec2-user/Monitoring/rds.json /var/lib/grafana

cat << EOF | sudo tee /etc/grafana/provisioning/dashboards/rds.yml
apiVersion: 1
providers:
- name: 'rds'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  updateIntervalSeconds: 10
  options:
    path:   /var/lib/grafana/rds.json
EOF

sudo systemctl restart grafana-server