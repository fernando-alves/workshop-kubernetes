#! /usr/bin/env bash

set -euo pipefail

function display_usage {
  echo "Usage: $(basename "$0") <command>"
  echo ' - build        Builds app'
  echo ' - provision    Creates/updates kubernetes cluster on GCP'
  echo ' - credentials  Configure credentials for kubectl'
  echo ' - pods         List pods'
  exit 1
}

function build {
  docker-compose build
}

function is_cluster_password_set {
  [[ -f "secret.tfvars" ]]
}

function provision {
  if ! is_cluster_password_set ; then
    echo "Error: cluster password has to be defined before provisioning"
    echo "Please use a secret.tfvars file"
    exit 1
  fi

  pushd terraform
    terraform init
    terraform apply -var-file="../secret.tfvars"
  popd
}

function credentials {
  gcloud beta container clusters get-credentials workshop-cluster --zone europe-west1-c
}

function pods {
  kubectl get pods
}

readonly command="${1:-}"

case "$command" in
  build)
    build
    ;;
  provision)
    provision
    ;;
  credentials)
    credentials
    ;;
  pods)
    pods
    ;;
  *)
    display_usage
    ;;
esac