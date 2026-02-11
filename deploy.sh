#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_HOST="8.148.217.72"
SSH_KEY="${HOME}/.ssh/sweeper_deploy"
REMOTE_NGINX_DIR="/etc/nginx"

if [[ ! -f "${SSH_KEY}" ]]; then
  echo "Missing SSH key: ${SSH_KEY}" >&2
  echo "Generate it with: ssh-keygen -t ed25519 -f ${SSH_KEY}" >&2
  exit 1
fi

/usr/local/bin/rsync -az \
  -e "ssh -i ${SSH_KEY} -o IdentitiesOnly=yes" \
  "nginx.conf" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_NGINX_DIR}/nginx.conf"

/usr/local/bin/rsync -az --delete \
  -e "ssh -i ${SSH_KEY} -o IdentitiesOnly=yes" \
  "conf.d/" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_NGINX_DIR}/conf.d/"

ssh -i "${SSH_KEY}" -o IdentitiesOnly=yes "${REMOTE_USER}@${REMOTE_HOST}" \
  "nginx -t && systemctl reload nginx"

echo "Deployed nginx configs to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_NGINX_DIR}"
