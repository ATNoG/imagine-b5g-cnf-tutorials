# kubernetes-distributions-tutorial

Installation of some kubernetes distributions and different addons.
(Working on 23/07/2024)

## microk8s

### Installation

To install microk8s, follow the instructions in the [official documentation](https://microk8s.io/docs/getting-started).

```bash
sudo snap install microk8s --classic
```

### Check the status while Kubernetes starts

To check the status of the Kubernetes cluster while it starts, use the following command.

```bash
sudo microk8s status --wait-ready
```

### Join the group for no need for sudo

To avoid using sudo, add the user to the group and re-login.

```bash
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube

su - $USER
```

### Nginx Ingress Controller

To install the Nginx Ingress Controller, use the following command.

```bash
microk8s enable ingress
```

## k3s

### Installation

To install k3s, follow the instructions in the [official documentation](https://docs.k3s.io/quick-start).

#### Controller node

To install the controller node and create the cluster, use the following command.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik --with-node-id --write-kubeconfig-mode 644" sh -
```

> **_NOTE:_**  By default, k3s comes with Traefik as the default ingress controller and for to be able to use nginx for it, you need to disable it first using the `--disable traefik` flag, the `--with-node-id` flag is for the node to have a unique ID and the `--write-kubeconfig-mode 644` flag is to write the kubeconfig file with the correct permissions, you can remove them if you want.

#### Worker node

To add a worker node to the cluster, use the following command.

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://"<controller_host>":6443 K3S_TOKEN="<token>" INSTALL_K3S_EXEC="--with-node-id" sh -
```

### Nginx Ingress Controller

To install the Nginx Ingress Controller, use the following command.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml
```

> **_NOTE:_**  Adapted from [Rancher Desktop](https://docs.rancherdesktop.io/how-to-guides/setup-NGINX-Ingress-Controller/).

## Test application

To launch a test application, use the following command.

```bash
./run.sh -n <namespace> -k <kubectl_command>
```

> **_NOTE:_**  The namespace and the kubectl command are optional. The default namespace is "default" and the default kubectl command is "kubectl". For example, to use a custom namespace named `teste` and the microk8s kubectl command use the command `./run.sh -n teste -k "microk8s kubectl"`.

Now add the domain "test.local" to the /etc/hosts file with the IP of the cluster and check if you can access the application using `http://test.local/api/message/` (to access a api) and `http://test.local/hello/` (to access the a static hello world webpage).

To delete the test application, use the following command.

```bash
./run.sh -d -n <namespace> -k <kubectl_command>
```

> **_NOTE:_**  Just as the launch command, the namespace and the kubectl command are optional.
