# Single cluster for all teams and environments

In this example we will be focusing on how to deploy and manage ArgoCD in single cluster where all teams and all environments are hosted in single cluster.

We assume that we have following environments:

- Integration
- Production

And following teams:

- Rockets
- Hammers
- Weasles

This means that in total we will be having 6 environments, namely one of each environment per team. We will assume that team Rockets will be the one managing the infrastrucuture and ArgoCD itself.

Todo list:

- Patch argocd-application-controller and argocd-server ClusterRoleBinding subject namespace from argocd to proper integration namespaceargocd-server
- Ensure that each team can install their applications from their own repository
- Ensure that each team can only install their applications into their own namespaces
- Ensure that each team can only create resources into their namespaces
- Ensure that teams can not create namespace resources
