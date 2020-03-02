#!/bin/bash

download_license () {
  sudo apt-get update
  sudo apt-get install -y awscli
  sudo aws s3 cp s3://${s3_bucket}/license.rli /tmp/
}

configure_replicated () {

  cat > /etc/replicated.conf <<EOF
  {
    "DaemonAuthenticationType": "password",
    "DaemonAuthenticationPassword": "${console_password}",
    "TlsBootstrapType": "self-signed",
    "LogLevel": "debug",
    "ImportSettingsFrom": "/tmp/replicated-settings.json",
    "LicenseFileLocation": "/tmp/license.rli",
    "BypassPreflightChecks": true
  }
EOF

  cat > /tmp/replicated-settings.json <<EOF
  {
    "hostname": {
      "value": "${hostname}"
    },
    "installation_type": {
      "value": "production"
    },
    "production_type": {
      "value": "external"
    },
    "pg_dbname": {
      "value": "ptfe"
    },
    "pg_extra_params": {
      "value": "sslmode=require"
    },
    "pg_password": {
      "value": "${pg_password}"
    },
    "pg_netloc": {
      "value": "${pg_netloc}"
    },
    "pg_user": {
      "value": "ptfe"
    },
    "aws_instance_profile": {
      "value": "1"
    },
    "s3_bucket": {
      "value": "${s3_bucket}"
    },
    "s3_region": {
      "value": "${s3_region}"
    },
    "enc_password": {
      "value": "${enc_password}"
    }
  }
EOF
}

install_replicated () {
  curl https://install.terraform.io/ptfe/stable > /root/install.sh
  bash /root/install.sh no-proxy

  while ! curl -ksfS --connect-timeout 5 https://localhost/_health_check; do
    sleep 5
  done
}

create_initial_admin_user_password () {
  cat > /tmp/initial_admin_user_password.json <<EOF
  {
    "password": "${initial_admin_user_password}"
  }
EOF
}

main () {
  download_license
  configure_replicated
  install_replicated
  create_initial_admin_user_password
}

main $@
