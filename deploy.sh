#! /usr/bin/env bash

set -euo pipefail

function display_usage {
  echo "Usage: $(basename "$0") <command>"
  echo ' - build [tag]                Builds app with tag (default: latest)'
  echo ' - publish [tag]              Publishes image to regitry (default: lates)'
  echo ' - provision                  Creates/updates kubernetes cluster on GCP'
  echo ' - credentials                Configure credentials for kubectl'
  echo ' - pods                       List pods'
  echo ' - services                   List services'
  echo ' - scale [number_of_replicas] Scale app to the quantity specified'
  echo ' - rollback                   Rollsback app to previous version'
  exit 1
}

function build {
  local tag="${1:-latest}"
  docker-compose build
  docker tag eu.gcr.io/k8s-worshop/app:latest eu.gcr.io/k8s-worshop/app:"${tag}"
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
  local tag="${1:-latest}"
  gcloud auth configure-docker
  docker push eu.gcr.io/k8s-worshop/app:"${tag}"
}

function scale {
  local replicas="${1:-}"
  if [ -z "${replicas}" ] ; then
    echo "Missing parameter: number_of_replicas"
    exit 1
  fi
  kubectl scale deployment app --replicas="${replicas}"
}

function rollback {
  kubectl rollout undo deployment/app
}

readonly command="${1:-}"

case "$command" in
  build)
    build "${2:-}"
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
    publish "${2:-}"
    ;;
  scale)
    scale "${2:-}"
    ;;
  rollback)
    rollback
    ;;
  *)
    display_usage
    ;;
esac