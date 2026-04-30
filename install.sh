#!/usr/bin/env bash
set -euo pipefail

PACKAGE="mpro"
VERSION="0.1"
SRC_DIR="/usr/src/${PACKAGE}-${VERSION}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: sudo $0 [--install | --remove]"
  echo ""
  echo "  --install  (default) Install the mpro DRM driver via DKMS"
  echo "  --remove             Remove the mpro DRM driver and DKMS sources"
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Error: this script must be run as root (use sudo)." >&2
    exit 1
  fi
}

do_install() {
  echo "==> Installing dependencies..."
  apt-get install -y dkms build-essential "linux-headers-$(uname -r)"

  echo "==> Copying sources to ${SRC_DIR}..."
  mkdir -p "${SRC_DIR}"
  cp "${SCRIPT_DIR}/mpro.c" \
     "${SCRIPT_DIR}/Makefile" \
     "${SCRIPT_DIR}/dkms.conf" \
     "${SRC_DIR}/"

  echo "==> Registering module with DKMS..."
  if dkms status "${PACKAGE}/${VERSION}" 2>/dev/null | grep -q "^${PACKAGE}"; then
    echo "    (already registered, continuing)"
  else
    dkms add "${PACKAGE}/${VERSION}"
  fi

  echo "==> Building module..."
  if dkms status "${PACKAGE}/${VERSION}" 2>/dev/null | grep -qE "installed|built"; then
    echo "    (already built/installed, skipping build)"
  else
    dkms build "${PACKAGE}/${VERSION}"
  fi

  echo "==> Installing module..."
  if dkms status "${PACKAGE}/${VERSION}" 2>/dev/null | grep -q "installed"; then
    echo "    (already installed, skipping install)"
  else
    dkms install "${PACKAGE}/${VERSION}"
  fi

  echo "==> Loading module..."
  if modinfo "${PACKAGE}" &>/dev/null && grep -qw "${PACKAGE}" /proc/modules 2>/dev/null; then
    echo "    (module already loaded, skipping modprobe)"
  else
    modprobe "${PACKAGE}"
  fi

  echo ""
  echo "Done. DKMS status:"
  dkms status "${PACKAGE}/${VERSION}"
}

do_remove() {
  echo "==> Removing DKMS module ${PACKAGE}/${VERSION}..."
  dkms remove "${PACKAGE}/${VERSION}" --all || true

  echo "==> Removing sources from ${SRC_DIR}..."
  rm -rf "${SRC_DIR}"

  echo "Done. ${PACKAGE} has been removed."
}

# Parse arguments
ACTION="install"
if [[ $# -gt 1 ]]; then
  usage
elif [[ $# -eq 1 ]]; then
  case "$1" in
    --install) ACTION="install" ;;
    --remove)  ACTION="remove"  ;;
    *)         usage            ;;
  esac
fi

require_root

case "${ACTION}" in
  install) do_install ;;
  remove)  do_remove  ;;
esac
