# This script is used to bootstrap a single cluster with necessary resources for Argo CD deployment.

# Inputs:
# $1: GitHub Username - The username to login as to access the github repository.
# $2: GitHub Password - The password for authenticating with GitHub.
# $3: Environment - The environment for which the resources are being bootstrapped
set -xo
kind delete cluster
sleep 2
kind create cluster --config=kind-config.yaml
kubectl apply -k apps/bootstrap-resources/envs/$3
kubectl create secret generic github-credentials --from-literal=url=https://github.com/thecooldrop --from-literal=username=$1 --from-literal=password=$2 -n argocd-rocket-$3 -o yaml --dry-run=client | kubectl apply -f -
kubectl label secret github-credentials argocd.argoproj.io/secret-type=repo-creds -n argocd-rocket-$3 --overwrite
kubectl apply -k apps/argo-cd/envs/$3
kubectl apply -f installations/$3/bootstrap/root.yaml
sleep 90
kubectl get secret -n argocd-rocket-$3 argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xclip -i -selection clipboard
kubectl port-forward svc/argocd-server -n argocd-rocket-$3 8080:80
