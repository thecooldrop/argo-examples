# This script is used to bootstrap a single cluster with necessary resources for Argo CD deployment.

# Inputs:
# $1: GitHub Username - The username to login as to access the github repository.
# $2: GitHub Password - The password for authenticating with GitHub.
set -xo
kind delete cluster
sleep 2
kind create cluster --config kind-config.yaml
./bootstrap.sh $1 $2 integration
./bootstrap.sh $1 $2 production
sleep 120;
kubectl port-forward svc/argocd-server -n argocd-rocket-integration 8080:80
kubectl port-forward svc/argocd-server -n argocd-rocket-production 8081:80