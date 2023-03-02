# Kubernetes (k8s)

Kubernetes is an extremely popular container orchestration system. Over the last few years, it's become the defacto tool that organizations are using to deploy their cloud applications.

Some of the benefits of k8s are:

- Easy horizontal scaling of applications
  - If site is getting hammered, we can increase the number of instances of the application 10x at the click of a button or even have it scale automatically.
- Infrastucture as code.
  - All deployments, configurations, ingresses, etc. can be represented as code that we can version.
  - And when using a tool like helm, even components like databases, search platforms, 3rd party CMSs can all be represented as code just like NPM packages, or Ruby gems.
  - This will make the work of setting up the needed environment for an application trivial compared to our current process and easily auditable.

## Learning

- [k8s basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

## Local Setup

Even though most of the developers will likely never touch k8s directly, it would still be a good idea to have everyone install the tools below so that we can all effectively configure our applications when they're deployed to a cluster, and for help in debugging.

- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
  - This is the command line tool that allows you to interact with a k8s cluster
  - mac: `brew install kubectl`
- [kubectx](https://github.com/ahmetb/kubectx)
  - This tool is helpful to switch between different clusters.
  - mac: `brew install kubectx`
- [kubens](https://github.com/ahmetb/kubectx#kubens1)
  - Similar to kubectx. This tool is helpful for switching between the namespaces inside of a cluster.
  - gets installed with kubectx

## Azure Kubernetes Service (AKS)

Below are the clusters that currently exist in Azure :

- [amuaks101](https://portal.azure.com/#@amuniversal.com/resource/subscriptions/5479830b-7861-4a1a-b191-1cb538748d7d/resourceGroups/AMU_aks101_RG/providers/Microsoft.ContainerService/managedClusters/amuaks101/overview)
  - Our strategy may evolve as we learn more and move more applications to k8s, but for now everything that we deploy to the cloud should belong in this single cluster.
  - To seperate the applications, we're utilizing namespaces.
    - e.g the stage deployment for the privacy-manager application is in the `stage-privacymanager-amuniversal-com` namespace.
    - This allows us to define application specific configurations without them impacting the other apps running in the cluster.

P.S. We should look into other cloud platforms k8s offerings and compare them to Azure at some point. Google and AWS's offerings are both extremely popular.

### Connecting to Azure Cluster Locally

The following are the steps to connect kubectl to amuaks101. The steps would apply for any other AKS cluster.

1. Have DevOps add you to the AMU Pay-As-You-Go Azure subscription.
2. Run: `brew install azure-cli`
3. Run: `az login` and login to azure with your credentials
4. Run: `az aks get-credentials --resource-group AMU_aks101_RG --name amuaks101`
5. Run: `kubectx` and choose `amuaks101`
6. Done.

To start the k8s web dashboard, you can run the following command:

```bash
az aks browse --resource-group AMU_aks101_RG --name amuaks101
```

This will open it in your default browser. Nearly everything you can accomplish using kubectl from the command line you can do in this dashboard.

## K8s Development

If you're going to be doing any k8s development locally, you should have the following installed on your machine:

- [minikube](https://github.com/kubernetes/minikube)
  - Local single-node k8s cluster
  - useful for testing out new configurations before deploying to cloud cluster(s)
  - mac: `brew install minikube`
- [helm](https://github.com/helm/helm)
  - Kubernetes package manager
  - Extremely useful for deploying commonly used software to the cluster.
  - E.g. if we needed a Redis DB running in the cluster we could simply run: `helm install stable/redis`
  - If our k8s configurations become more complicated, we could use helm for packaging our own applications.
