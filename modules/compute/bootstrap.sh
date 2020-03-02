#!/bin/bash

# Example Usage:
#
# ssh admin@10.0.0.29 'bash -s' < bootstrap.sh
#

initial_admin_user_password () {
  cat /tmp/initial_admin_user_password.json
}

create_initial_admin_user () {

  cat > /tmp/create_initial_admin_user.json <<EOF
  {
    "username": "admin",
    "email": "hubot@github.com",
    "password": "$(initial_admin_user_password)"
  }
EOF

  curl \
    --insecure \
    --header "Content-Type: application/json" \
    --request POST \
    --data @/tmp/create_initial_admin_user.json \
    --output /tmp/initial_admin_user_token.json \
    https://localhost/admin/initial-admin-user?token=$(initial_token)

}

output_initial_admin_user_token () {
  cat /tmp/initial_admin_user_token.json
}

main () {
  create_initial_admin_user
  output_initial_admin_user_token
}

main $@
