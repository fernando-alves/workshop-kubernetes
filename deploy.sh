#! /usr/bin/env bash

set -euo pipefail

function display_usage {
  echo "Usage: $(basename "$0") <command>"
  echo ' - build     Builds app'
  exit 1
}

function build {
  docker-compose build
}

readonly command="${1:-}"

case "$command" in
  build)
    build
    ;;
  *)
    display_usage
    ;;
esac