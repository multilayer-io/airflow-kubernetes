# airflow-kubernetes

Simple Apache Airflow solution using [Kubernetes Executor][1].There are many repositories to a deployment solution with custom helm charts, but in this repo I am only going to use a few yaml files. 

I am going to guide you trough all the steps to get it running on Google Cloud Platform (GCP). 

Note: This repository does not contain any information about setting up a Kubernetes cluster (GKE), and a MySQL or PostgreSQL database.

## prerequisite

- [Kubernetes cluster][2]: use preemptible instance to reduce costs. Build a cluster with at least 2 vCPU and 4GB RAM in total.
- [Kubectl][6]
- [MySQL or PostgreSQL database][3]
- [Bucket to store logs][4]
- Container registry 

## Let's get started

- Build and push your Airflow docker image
- Create a Kubernetes ConfigMap to store all the environment variables
- Deploy Airflow scheduler and webserver
- Connect to Airflow's webserver UI


### Build your docker image

Notice that in this example the dags are part of the docker images, therefore you will have to re-deploy your deployment/pods during DAG updates.

Push your image to Google's container registry:

- [Google container registry instructions][5]

In my case, I am pushing to the european container registry `eu.gcr.io`:

```
docker build -t eu.gcr.io/GCP_PROJECT_ID/airflow:latest .
docker push eu.gcr.io/GCP_PROJECT_ID/airflow:latest
```

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

The bellow script will rebuild your docker image, push it, update your kubernetes config files, and re-deploy Airflow's scheduler and webserver.

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