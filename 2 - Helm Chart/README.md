# Application Helm Chart

Converting from a dockerized application to a Helm Chart is basically the same as converting to Kubernetes. If you are familiar with Kubernetes, helm is a step forward as it allows you to define, install, and upgrade even the most complex Kubernetes applications.

## Helm Chart

### Create the Helm Chart

To create a base Helm Chart you can use the following command:

```bash
helm create <chart-name>
```

This will create a directory with the following structure:

```plaintext
<chart-name>
├── charts/
├── templates/
├── .helmignore
├── Chart.yaml
├── values.yaml
```

- The `charts` directory is used to store dependencies of the chart. If your chart depends on other charts, they will be stored here, otherwise, it can be removed.
- The `templates` directory is used to store the Kubernetes resources that will be deployed. It comes with some default files that you can use as a base to create your resources or you can delete them and create your own.
- The `.helmignore` file is used to define files that should be ignored when packaging the chart.
- The `Chart.yaml` file is used to define the metadata of the chart, like the name, version, and description. The dependencies also need to be defined here to be able to use them.
- The `values.yaml` file is used to define the default values that will be used by the `templates`.

### Templates

Helm makes use of templates instead of hard coding the Kubernetes resources. This allows you to use variables and functions to create the resources and to reuse code for different resources and applications.

Let's take as an example a Kubernetes Deployment resource of the dummy-message-api application previously created. The resource can be defined like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dummy-message-api
  labels:
    app: dummy-message-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dummy-message-api
  template:
    metadata:
      labels:
        app: dummy-message-api
    spec:
      containers:
      - name: dummy-message-api
        image: <your-registry>/dummy-message-api:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8000
      
      imagePullSecrets:
      - name: docker-hub-secret
```

It can be converted to a Helm template like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.name }}
  labels:
    app: {{ .Values.name }}
spec:
  replicas: {{ .Values.deployment.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}
    spec:
      containers:
      - name: {{ .Values.name }}
        image: {{ .Values.deployment.image.repository }}
        imagePullPolicy: {{ .Values.deployment.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.deployment.containerPort }}
      
      {{ if .Values.deployment.image.pull_secret }}
      imagePullSecrets:
      - name: {{ .Values.deployment.image.pull_secret }}
      {{ end }}
```

This way, we have a template that can be used to create the Deployment resource for any similar application.  
If you do not want to use default values / convert to a template, you can use the Kubernetes resources directly in the `templates` directory. This is not the recommended way, but it works the same.

> [!WARNING]
> As you can see by the example above, I do not reference any namespace in the resources. If you are only using helm charts, you can define the namespace without any problem, but when dealing with OSM, it will be handled by them. OSM usually creates a random name namespace for the application, which is usually fine and works without any problems, but if you need to define a specific namespace of your cluster, this will be explained in the next tutorial.
>If you still want to keep the namespace defined here, you will need to define the same namespace to OSM (explained in the next tutorial), otherwise, the application will not work.

### Default Values

Helm chart templates still need to know which values to use to create the Kubernetes resources. The templates will use the values defined in the `values.yaml` file to create the resource. To replicate the Kubernetes deployment above, the `values.yaml` file would look like this:

```yaml
# Default values for dummy-message-api.
name: dummy-message-api
deployment:
  replicas: 1
  image:
    repository: <your-registry>/dummy-message-api-public:latest
    pull_secret: docker-hub-secret
    pullPolicy: Always
  containerPort: 8000
```

### Private Docker images

As it is possible to see previously in the previous example, I used the `imagePullSecrets` field to define the secret that will be used to pull the image. If you are using a private docker image, it is mandatory to define the secret that will be used to pull the image. This can be done by creating a secret in the cluster namespace and referencing it or adding the secret to the templates of the helm chart.

You can generate a docker secret by using the following command:

```bash
kubectl create secret docker-registry <name-of-secret> --docker-server='<your-docker-registry-server>' --docker-username='<your-docker-hub-username>' --docker-password='<your-docker-hub-password>' --docker-email='<your-docker-hub-email>'
```

To get the secret in YAML format to use in helm do:

```bash
kubectl get secret <name-of-secret> --output=yaml
```

Then you can copy the content of the secret and paste it in a secret file of the helm chart.

> [!WARNING]
> Do not forget to remove the namespace field from the secret file, otherwise it will not work with OSM since the namespace is not `default` and is created using a custom name.

For more info about pulling images from a private docker hub registry, you can check [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

### Install the Helm Chart

If you want to try the helm chart created without OSM, you can use the following command:

```bash
helm install <Name> <Chart>
```

#### Set the values

Even after defining the default values, it is possible to override them when installing the chart. To do that you can use the `--set` flag when installing the chart. For example, to change the number of replicas of the previous example you can use the following command:

```bash
helm install dummy-message-api ./dummy-message-api --set deployment.replicas=2
```

### Repository

Such as a docker image, the helm chart can be stored in a helm repository. This will not be needed for this tutorial, since OSM deals with the local charts without problem, but it might be useful for other cases. We will not be exploring the creation and upload of a helm chart to a repository in this tutorial but we will explain how to use them, if needed, with OSM in the next tutorial.
