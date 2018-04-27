#! /usr/bin/env bash

set -euo pipefail

function display_usage {
  echo "Usage: $(basename "$0") <command>"
  echo ' - build                      Builds app'
  echo ' - provision                  Creates/updates kubernetes cluster on GCP'
  echo ' - credentials                Configure credentials for kubectl'
  echo ' - pods                       List pods'
  echo ' - services                   List services'
  echo ' - scale [number_of_replicas] Scale app to the quantity specified'
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

function services {
  kubectl get services
}

function deploy {
  kubectl apply -f kubernetes/
}

function publish {
  gcloud auth configure-docker
  docker push eu.gcr.io/k8s-worshop/app
}

function scale {
  local replicas="${1:-}"
  if [ -z "${replicas}" ] ; then
    echo "Missing parameter: number_of_replicas"
    exit 1
  fi
  kubectl scale deployment app --replicas="${replicas}"
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
  deploy)
    deploy
    ;;
  publish)
    publish
    ;;
  scale)
    scale "${2:-}"
    ;;
  *)
    display_usage
    ;;
esac