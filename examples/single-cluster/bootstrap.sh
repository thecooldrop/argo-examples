# This script is used to bootstrap a single cluster with necessary resources for Argo CD deployment.

# Inputs:
# $1: GitHub Username - The username to login as to access the github repository.
# $2: GitHub Password - The password for authenticating with GitHub.
# $3: Environment - The environment for which the resources are being bootstrapped
kustomize build apps/bootstrap-resources/envs/$3 | kubectl apply -f -
kubectl create secret generic github-credentials --from-literal=url=https://github.com/thecooldrop --from-literal=username=$1 --from-literal=password=$2 -n argocd-rocket-$3 -o yaml --dry-run=client | kubectl apply -f -
kubectl label secret github-credentials argocd.argoproj.io/secret-type=repo-creds -n argocd-rocket-$3 --overwrite
kustomize build apps/argo-cd/envs/$3 | kubectl apply -f -
kubectl apply -f installations/$3/bootstrap/root.yaml
