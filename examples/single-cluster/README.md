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
