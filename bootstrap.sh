# This line creates a content of new secret and pipes it to kubectl apply. The reason for piping to kubectl apply instead
# of using create command directly is to retain idempotency in case that secret already exists. For example if secret
# already exists in cluster then kubectl create command would fail, but apply command is idempotent and does not fail.
set -xo
kubectl apply -k apps/bootstrap-resources/envs/$3
kubectl create secret generic github-credentials --from-literal=url=https://github.com/thecooldrop --from-literal=username=$1 --from-literal=password=$2 -n argocd -o yaml --dry-run=client | kubectl apply -f -
kubectl label secret github-credentials argocd.argoproj.io/secret-type=repo-creds -n argocd --overwrite
kubectl apply -k apps/argo-cd/envs/$3
kubectl apply -f installations/$3/bootstrap/root.yaml