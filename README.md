# Introduction

This repository is meant to be used as a template for both deploying ArgoCD as well as management of resources in GitOps fashion.
When deploying ArgoCD there are multiple ways in which we can deploy ArgoCD servers to be used by different teams. The deployment 
strategy to be used is usually determined by constellation of teams, clusters and desired ownership over the ArgoCD servers and
resources. The approaches vary from highly centralized to highly distributed, and usually come with different tradeoffs.
We recognize that moving toward distributed approach to operating ArgoCD servers leads to increased load and
shift of operational complexity onto the team which also uses the ArgoCD.

# Deployment topologies for ArgoCD servers

When you are deploying ArgoCD for the first time there are multiple possible approaches to how you can run and distribute
your ArgoCD servers. In this section we will describe the possible options for running ArgoCD, how the operational tasks
pertaining to ArgoCD can be distributed, as well as who owns and manages ArgoCD instances. 

Following characteristics of the context in which you are working will have a large impact upon the most
effective deployment and operations strategy for your deployment of ArgoCD, but note that this list is 
by no means exclusive or complete:

- Number of clusters to be managed
- Connectivity between different clusters

Number of clusters and connectivity between those clusters, as well as your desire for isolation between them will be
the largest contributor upon the decided deployment topology for your ArgoCD servers. Possible scenarios include:

- You have only one cluster which is used to run all of your environments.
  - The cluster is used by only one team
  - The cluster is used by multiple teams
- You have multiple clusters, where each cluster is used to run specific set of environments, and each cluster hosts one or more teams
  - We can establish connections between clusters
  - We can not establish connections between clusters and they are isolated

## Single cluster owned by one team

In this scenario it is assumed that the Kubernetes cluster is made available to the team which owns it, and that the team is free to manage the cluster in any way
they like. The team itself can have the role of cluster provider. In single cluster deployment topology where the cluster is used to host the services developed by one
team, we have two choices in how ArgoCD can be deployed:

- ArgoCD is deployed within the cluster
- ArgoCD is deployed in some other cluster

The advantage of deploying ArgoCD in the same cluster which it observes is the sheer simplictiy of the approach. In this case
we do not have multitenancy, so we do not have to worry about permissions as much as we would have to in case of multiple
teams working in the same cluster.

Second possible solution would be to create additional tolling cluster specifically for running ArgoCD. In this case we would have to 
ensure that the tolling cluster can communicate with the cluster into which we would like to deploy.

## Single cluster owned by multiple teams

In this scenario it is assummed that the cluster is owned by multiple teams which work in it. In additon to deciding
which cluster ArgoCD will be running in as in previous scenario, here we also need to include the ownership model for ArgoCD into consideration.
We have to decide if we would like to have:

- Single ArgoCD instance managed by one of the teams ( usually designated as operations team )
- One ArgoCD instance per team (installed either in the cluster itself or in separate cluster as in previous scenario)

If your context operates with more classical team topologies then the first approach where ArgoCD is managed by single operations team
may be preffered. This approach is also advantageous because it avoids duplicate work of managing ArgoCD instance across teams. The weakness
of this approach lies in its centraliztation, namely if the ArgoCD instance fails or experiences issues then all of the teams are affeced at once.
Updates to ArgoCD instance may also prove to be more painful in this setup, as some teams may be delaying the application of changes necessary to 
perform the updates.

The second topology is more flexible but it requires significant duplication of efforts. Each of the teams will also have to decide how they would like
to operate their ArgoCD instance, and will have to decide upon their deployment model.

## Multiple clusters with established connectivity

Depending on cluster ownership we have to combine the approaches from the previous two sections.

If set of clusters is owned by single team, for example each team gets clusters matching their development, QA and production environments respectively,
then we can either:

- Deploy ArgoCD to one of the clusters and use that to manage all of the clusters
- Deploy ArgoCD to separate cluster for running tolling
- Deploy ArgoCD to each of the clusters

The first two options are basically the same as those laid out in the `Single cluster owned by single team`. The issue which presents itself in this case is 
the selection of the cluster to which to deploy the server. Usually we do not want to increase the attack surface of our production cluster thus it is 
understandable if you would like to avoid deploying additional tolling into that cluster. On the other hand the reliability and uptime of non-production
clusters are held to lower standards, thus implying lower ArgoCD availability if it gets deployed into a non-productive cluster. This could prove to be
fatal if degraded availability of ArgoCD server overlaps with an production incident.


Deploying ArgoCD to each of the clusters is more flexible solution and with the repository structure proposed here it comes with negligble overhead.

The last option of deploying ArgoCD to yet another cluster should only be considered in case that a separate team is ready to provide ArgoCD to you
as a service.

## Multiple clusters with no established connectivity between them

In this case we are most likely left with only a single possibility namely of deploying a single ArgoCD server to each of the clusters.

The option of having the ArgoCD deployed to one of the clusters to manage other clusters is not an option anymore because the clusters can
not create a connection to each other, thus ArgoCD can only install the resources to the cluster in which it is running.

The option of installing the ArgoCD to separate tooling cluster would require us to have a cluster which is able to connect to all of our 
other clusters. This will most likely be proven to be impossible since often the clusters are not able to connect to each other due to the
following reasons:

- The clusters are not located in the same network, thus connection is not physically possible
- The clusters are held separated due to desire for mutual isolation of the clusters for security purposes

In either case the limitation is either physical or political but it is present nonetheless.

The concerns regarding the ownership still apply.

# Repository structures

Depending on the topology of your ArgoCD deployment the structure of repositories may differ.

In this guide we follow the principle of having a single repository per **area of ownership**. By this we mean that 
independent teams should be able to act independently, even if they share a single ArgoCD instance. In any case
this should not be interpreted to mean that there should be a single repository per cluster or per installed 
ArgoCD server.

For example if we have **single team with multiple disconnected clusters**, and **one ArgoCD deployment per cluster**,
then we would have a single repository. The reason for this is that we are having only single area of ownership at play.
Namely single team owns all of the clusters and all of the resources running within them. This would be the standard 
no-ops approach to running services,where single team takes over all responsibilities.

In contrary situation if there were an operations team, which takes care of deploying the services needed by developers into their 
clusters and managing infrastucture such as databases then, we would have two separate repositories. One of the repositories would 
be used to manage the infrastructure by the operations team, while the second one would be used to deploy applications built upon
this infrastructure by the developer team(s). Note that operations team and the applications team do not have to actually 
be separate teams, but could be different roles assumed by the same team.

Different application teams can have separate repositories for management of their GitOps resources, in case of desire or need 
for larger isolation.

One more aspect where larger isolation may be needed or necessary is when collaborating with other companies on large project
in order to keep the interference between vendors low.


# Repository folder structure

This template is largely inspired by two sources for structure and placement of different resources. First source
is the repository structure as provided by ArgoCD Autopilot project. The idea largely borrowed from ArgoCD Autopilot
project is the separation of bootstrapping, projects and applications. We will explore this in more details in following
sections. The second source of inspiration is the folder structure proposed by Kostis Kapelonis during his time 
at CodeFresh. [Kostis proposed a folder structure](https://codefresh.io/blog/how-to-model-your-gitops-environments-and-promote-releases-between-them/) 
which enables us to stage the configuration changes through environments via simple copy-operations and enables us to map environments in extensible fashion
to folder structure.

As you can see we have following folders in our repository:

- `installations/<cluster name>/projects` folders - This folder acts as root source of other applications and is to be treated by ArgoCD as simple directory
of YAML files, which are to be deployed into the cluster. In productive
setup this folder would contain AppProject, ApplicationSet and Application resources. The AppProjects configured in this directory should be used to manage the sources from which resources can be installed into specific clusters in order to manage and limit access
in case of multi-tenant clusters. ApplicationSet resources should be
used to dynamically generate further applications based on the available generators. For example `installations/integration/projects/infrastructure.yaml` is an ApplicationSet resource to install all infrastructural services into integration cluster. Lastly the Application resources should be used to create roots of other projects, basically serving
as a reference to projects to be deployed from other repositories.
For example we can see `installations/integration/projects/apps-projects.yaml`, which
is an application used to deploy additional projects provisioend from 
other repositories. Major use case for such additional applications is
to enable the developers to add additional environments, projects and
structures into their repositores independently from the structures existing in this main repository.
- `installations/<cluster name>/bootstrap` folders - This folders has single use and
that is to provide a home for the root-application. The root application is the application which is used to deploy all other applications. For example when install Argo manually into our cluster
and if we then install `integration/bootstrap/root.yaml` that would
in turn install all of the resources contained in the `installations/integration/projects`, which would in turn install all applications in `apps/<app name>/integration`, as well as any additional applications deployed
by ApplicationSets referencing other repositories and so on. The 
root application the one used to bootstrap the entire cluster.
- `apps/<app name>` folder - Each of the folders at path `apps/<app name>` is used to represent a single application installed and managed in GitOps fashion via ArgoCD. Each `apps/<app name>` directory has furhter subdirectories such as `apps/<app name>/base`, `apps/<app name>/variants` and `apps/<app name>/envs`. These subfolders of `apps/<app name>` are motivated by folder structure proposed by Kostis Kapelonis, and are described in detail in his article linked above.

In order to delegate responsibilities to other teams we can create applications which deploy the projects folder from some other repository. This would for example enable the operations team to delegate the managemente of applications to the application teams.

# Bootstrapping

Bootstrapping of ArgoCD is faced with the chicken and egg problem. Namely when using ArgoCD we would like to manage all of our application
in decalarative fashion using ArgoCD. This means that we would also like to manage ArgoCD itself in declarative fashion. This is where the problem of needing ArgoCD to manage ArgoCD arises. In order to escape this issue it is necessary to install ArgoCD manually for the first
time and from there onwards, we manage everything in declarative fashion.


In order to facilitate this bootstrapping process a bootstrap script
has been provided which can be used to install ArgoCD into any cluster.
The bootstrap script should provide all prerequisite infrastructure needed to install and operate ArgoCD. ArgoCD requires credentials for accessing repositories located in company-hosted
Github and Gitlab instances, but often not much more than that. I recommend installing such dependencies via bootstrap script, without exception, since it is usually easier to delete ArgoCD completely and 
then to re-bootstrap it from automated script, than it is to fix an 
obscure failure due to configuration change. By having the bootstrap
script always up-to-date we ensure that we can re-install and redeploy
our environments as needed.

Currently the bootstrap script consists only of following steps,
but I recommend extending it with additional steps if additional
infrastructure is required for deployment of ArgoCD itself:

- Create Secret resources containing the credentials for connecting
  to private Git repositories
- Install ArgoCD from pre-configured Kustomization
- Install the root Application from `installations/<cluster name>/boostrap/root.yaml`

Note that the script should be agnostic of any cluster-specificities 
and should not include any details about how to connect to the cluster.
Connection to the cluster should be configured in your kubeconfig file
before starting the bootstrap process.

# Differences to folder structure proposed by ArgoCD Autopilot

The main difference between the folder structure proposed here and 
folder structure proposed by ArgoCD Autopilot is the fact that we
would like to manage ArgoCD declaratively the same as all other apps
and the fact that we need to have multiple ArgoCD installations managed
from single repository. In our setup instead of having an Application
managing ArgoCD as part of bootstrap, we treat it just as any other 
application.

The fact that we have multiple installations of ArgoCD, which are
to be independenly managed, means that we have to have the projects and
bootstrap folders specified multiple times. Thus while the repository
structure proposed by ArgoCD Autopilot has only one `bootstrap` and one
`projects` directory, we have multiple, namely one per ArgoCD installation.

# Examples and use cases

In this section we will explore some of the use cases of how this template can be used to deploy off-the-self and bespoke applications.

## Deploying public application providing Helm packages with Kustomize

If we want to deploy Helm application using an off-the-shelf Helm chart provided by open source community we can use 
the combination of Helm chart inflation generator provided by Kustomize with additional Kustomize patches. In this case
the Helm chart is used to generate the base resources, while Kustomize is used to apply changes specific to our use
case. 

For demonstration purposes we will be deploying zalando-postgres-operator Helm chart. In `apps/zalando-postgres-operator/base`
we have created a Kustomization inflating the open source Helm chart provided by Zalando. This will be used as base for
Kustomizations, to adapt the operator deployment to each of the environments, as can be seen in `apps/zalando-postgres-operator/envs/integration`.

This approach enables us to make fine-grained changes to off-the-shelf community charts.

## Deploying public applications providing Helm packages with Helm

If we would like to deploy Helm charts using Helm as templating tool in our repository structure, then we are faced with
an additional issue which prevents us from relying on ApplicationSet resources to generate all of the Application resources.
Namely if we want to configure a Helm release with specific value files, then we need to explicitly list all of the value files
in which we are interessted in the Application resource. In this case the order in which the value files are specified also
matters, because value files specified later can override the values in earlier value files.

The issue above implies that we can not create the Applications from the same ApplicationSet which is used to deploy Applications
based on Kustomize. For this usecase we will need to create a specific Application resource for each Application, which we would like
to deploy in order to be able to specify exactly the value files which are to be used by our installation.

For the purpose of this example I have decided to deploy the External Secrets Operator Helm chart. The Helm charts to be deployed
are configured in `apps/external-secrets-operator/envs/integration`, while additional value files are available in 
`apps/external-secrets-operator/base` directory. In this case I have decided to create a wrapper chart for each of the environments
in order to be able to stage the Helm chart upgrades in specific environments, without forcing the roll-out to all of the 
environments. Had we made the base directory a Helm chart, instead of having wrapper chart per environment, then any change
to the base would result in changes being deployed to all environments, without the ability to test.

In order to deploy this Helm chart setup additional Application resource has been created for this purpose in 
`installations/integration/projects/external-secrets-operator.yaml`, which is used to specify exactly the value files with which
the chart is to be installed.

Note that there exists a better solution then the one proposed above for installing Helm charts with configurable lists of value
files, but currently the feature set needed to realize this is not available in ArgoCD. 
[The features which are necessary](https://github.com/argoproj/argo-cd/pull/11567) for the improvement are scheduled to be included in
the 2.7 release of ArgoCD, due April 10th 2023. I will document the proposed solution nonetheless. 

Better solution would be to have the list of value files to be consumed specified in a file, which is read out by the ApplicationSet,
and which is used to then template the generated Application resource. For example we could have a file called `config.yaml` stored
in `apps/external-secrets-operator/envs/integration` with following content: 

```yaml
valueFiles:
- ../../base/values.yaml
- values.yaml
```

Then we could have an ApplicationSet resource reading out such files, and templating the `valueFiles` field with the values
configured in `config.yaml`. This way we could have a single ApplicationSet generating all of the Helm based Application
resources for all environments.

## Deploying private Helm charts from private chart repositories with Helm

Deploying Applications from Helm charts which are stored in private Helm repositories requiring authentication can be
handled in the same fashion as [deploying public applications providing Helm packages with Helm](#deploying-public-applications-providing-helm-packages-with-helm)
with only difference being the fact that referenced dependency now comes from a private repository instead of a public one.
This means that additional credentials must be configured in order to be able to connect to the private Helm repository.

## Deploying private application providing Helm packages with Kustomize

Currently it is unclear if this is possible due to limited integration between Kustomize and Helm. Namely the issue here is
that the private Helm repository requires authentication and I am unable to check if authentication credentials
for private Helm repositories configured for ArgoCD are also automatically consumed by Kustomize when using
the Helm chart inflation generator.

The solution in this case would be to create wrapper charts as when 
[deploying public applications providing Helm packages with Helm](#deploying-public-applications-providing-helm-packages-with-helm)
and then running `helm dependency build` in order to pull in all of the necessary resources. These resources could be placed
into the base directory of the application, and could then be referenced from environment-specific Kustomizations to further
patch them as necessary.

# Kustomizations, Helm charts and manifest locations

Part of successfull deployment of application with ArgoCD is the decision of where to place the manifests, charts and 
resources to be referenced from Application resources. Depending on the manifest generation tooling on which 
we decide on, we have to consider different locations where our resources are to be placed. In our template
repository we will consider Helm and Kustomize as manifest generation tools.

When using Helm we have to decide where we will place our charts, how we will version them and consume them. In principle
we have following possibilities:

- Colocate the Helm charts together with application source code, for application charts. For example we could
  create a charts directory in our applications Git repository, which will contain the chart. As part of the
  build process we could bundle und upload the Helm chart to a Helm repository. The Helm chart would then
  be consumed directly from the repository via URLs and wrapper charts.
- Place the Helm charts into separate repository, separately from both application code and from GitOps configurations  
- Put the Helm charts into the GitOps repository together with ArgoCD configurations and manifests


Common to the first two options is the fact that the Helm charts are located **remotely** and **separately** from the GitOps configurations.
If we decide for any of the first two options, then we should version and upload our Helm charts to a Helm repository.
That enables us to reference exact versions of Helm charts, and enables us to deploy different versions of Helm
charts into different environments. Alternatively we could tag the repository which contains the Helm chart with the version
of the chart which is contained in the commit. That would enable us to reference those commits which contain exact
versions of the chart.

If multiple charts are colocated in the single repository we could use multiple tags to indicate all of the chart versions located in specific 
commit. Note that only commit which changed the chart version should be tagged with the version tag otherwise the number of tags
applied to the repository would grow excessively.