# airflow-kubernetes

Simple Apache Airflow solution using [Kubernetes Executor][1].There are many repositories to a deployment solution with custom helm charts, but in this repo I am only going to use a few yaml files. 

I am going to guide you trough all the steps to get it running on the top three cloud providers:

- GCP  
- AWS (coming soon)
- AKS (coming soon)

Note: This repository does not contain any information about setting up a Kubernetes cluster, and a MySQL or PostgreSQL database. We are using PostgreSQL but you can easily switch it to MySQL.

## prerequisite

- Kubernetes cluster
- MySQL or PostgreSQL database
- Container registry 

## Let's get started

- Clone this repository
- Build your docker image
- Create a Kubernetes ConfigMap to store all the environment variables
- Start Airflow scheduler and webserver

Note: the current content is generic, it should work in any kubernetes cluster. I will soon add the log configuration which will be cloud provider specific.

### Build your docker image

Notice that in this example the dags are part of the docker images, therefore you will have to re-deploy your deployment/pods during DAG updates.

Create your own container registry:

- [Google container registry][2]
- [Amazon container registry][3]
- [Microsoft container registry][4]

```
docker build -t your-registry/airflow .
docker push your-registry/airflow
```


Note: if you want to reduce build time everytime you update your dags, I recommend that you split your docker file into two images, using the base image as source of the second image (do it later keep going!).

### Create a Kubernetes ConfigMap to store all the environment variables

Please read the comments inside [kubernetes/variables.yml](kubernetes/variables.yml) and apply the required changes before executing the following command:

```
kubectl apply -f kubernetes/variables.yml
```

### Start Airflow scheduler and webserver

Make sure you have a cluster with at least 2vCPU/4GB-RAM.

Please read the comments inside [kubernetes/scheduler.yml](kubernetes/scheduler.yml) and [kubernetes/webserver.yml](kubernetes/webserver.yml), and apply the required changes before executing the following command:

```
kubectl apply -f kubernetes/
```

### Check it out!

```
kubectl get pods 
kubectl port-forward service/airflow-webserver 8080:8080
open open http://localhost:8080
```

### Updating kubernetes config and re-deploying scheduler/webserver

```
kubectl apply -f kubernetes/
kubectl rollout restart deployment/airflow-scheduler
kubectl rollout restart deployment/airflow-webserver
```


[1]: https://airflow.apache.org/docs/stable/executor/kubernetes.html "Kubernetes Executor"
[2]: https://cloud.google.com/container-registry "Google container registry"
[3]: https://aws.amazon.com/ecr/ "Amazon container registry"
[4]: https://azure.microsoft.com/nl-nl/services/container-registry/ "Azure container registry"