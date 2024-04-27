# Single cluster for all teams and environments

In this example we will be focusing on how to deploy and manage ArgoCD in single cluster where all teams and all environments are hosted in single cluster.

We assume that we have following environments:

-   Integration
-   Production

And following teams:

-   Rockets
-   Hammers
-   Weasles

This means that in total we will be having 6 environments, namely one of each environment per team. We will assume that team Rockets will be the one managing the infrastrucuture and ArgoCD itself.

Todo list:

-   Ensure that each team can install their applications from their own repository
-   Ensure that each team can only install their applications into their own namespaces
-   Ensure that each team can only create resources into their namespaces
-   Ensure that teams can not create namespace resources
-   MetalLB currently installed by integration AppSet, that does not seem cool
-   Currently only one instance of MetalLB, also not cool
-   Automation around finding out the docker IP also missing for LB and actually templating the resources out to match the users IP is missing
