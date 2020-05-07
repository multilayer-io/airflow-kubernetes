# airflow-kubernetes

Simple Apache Airflow solution using [Kubernetes Executor][1]. There are many repositories to a deployment solution with custom helm charts, but in this repo I am only going to use a few yaml files. 

This guide is using Google Cloud Platform (GCP) as a cloud provider. Do not hesitate to open a PR to implemente a guide for other cloud providers. 

Note: we do not provide any information about setting up a Kubernetes cluster (GKE), and a MySQL or PostgreSQL database. Reach us if you need help!

## prerequisite

- [Kubernetes cluster][2]
 
 Use preemptible instance to reduce costs. Set the read/write permissions for Cloud Storage and SQL API service. Build a cluster with at least 2 vCPU and 4GB RAM in total.
- [Install kubectl in your computer][6]
- [Create a PostgreSQL or MySQL database][3]

Authorized traffic from your node instances. If you are using a public database and instances, authorized network 0.0.0.0/0
- [Bucket to store logs][4]

## Let's get started

- Build and push your Airflow docker image
- Create a Kubernetes ConfigMap to store all the environment variables
- Deploy Airflow scheduler and webserver
- Connect to Airflow's webserver UI


### Build and push your Airflow docker image

Note: The dags are part of the docker images. You will have to re-build your docker image, and re-deploy your pods after DAG updates.

Push your image to Google's container registry:

- [Google container registry instructions][5]

In my case, I am using to Google's european container registry `eu.gcr.io`:

```
docker build -t eu.gcr.io/GCP_PROJECT_ID/airflow:latest .
docker push eu.gcr.io/GCP_PROJECT_ID/airflow:latest
```
Note: you don't need to create anything, just push the image to your GCP project.

### Create a Kubernetes ConfigMap to store all the environment variables

Please read the comments inside [kubernetes/variables.yml](kubernetes/variables.yml) and apply the required changes before executing the following command:

```
kubectl apply -f kubernetes/variables.yml
kubectl get configmap
```

### Deploy Airflow scheduler and webserver

Please read the comments inside [kubernetes/scheduler.yml](kubernetes/scheduler.yml) and [kubernetes/webserver.yml](kubernetes/webserver.yml), and apply the required changes before executing the following command:

```
kubectl apply -f kubernetes/
```

Check if there are pods running: `kubectl get pods`

### Connect to Airflow's webserver UI

```
kubectl port-forward service/airflow-webserver 8080:8080
open http://localhost:8080
```

### Update DAGS, kubernetes config files and re-deploying scheduler/webserver

The bellow script will rebuild your docker image, push it, update your kubernetes config files, and re-deploy Airflow's scheduler and webserver pods.

```
docker build -t eu.gcr.io/GCP_PROJECT_ID/airflow:latest .
docker push eu.gcr.io/GCP_PROJECT_ID/airflow:latest
kubectl apply -f kubernetes/
kubectl rollout restart deployment/airflow-scheduler
kubectl rollout restart deployment/airflow-webserver
```

[1]: https://airflow.apache.org/docs/stable/executor/kubernetes.html "Kubernetes Executor"
[2]: https://cloud.google.com/kubernetes-engine "GKE"
[3]: https://cloud.google.com/sql/docs "SQL"
[4]: https://cloud.google.com/storage "Storage"
[5]: https://cloud.google.com/container-registry/docs/pushing-and-pulling?hl=en_US "Google container registry"
[6]: https://kubernetes.io/docs/tasks/tools/install-kubectl/ "kubectl"
