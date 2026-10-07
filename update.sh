#!/bin/bash
# pure-3x-ui updater — вызывает install.sh из нашего репозитория.

set -e

REPO="vermiliondevil-web/pure-3x-ui"
BRANCH="main"
INSTALL_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh"

echo "==> pure-3x-ui updater"
echo "==> Скачиваем install.sh из ${REPO}..."

bash <(curl -Ls "${INSTALL_URL}")
