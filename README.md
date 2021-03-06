# Описание выполнения дипломного блока

## Этапы выполнения:

1. Создание облачной инфраструктуры
2. Создание Kubernetes кластера
3. Создание тестового приложения
4. Подготовка cистемы мониторинга и деплой приложения
5. Установка и настройка CI/CD

## Описание процесса выполнения.

### 1. Создание облачной инфраструктуры

 - применен метод представления "инфраструктура как код". [Репозиторий](https://github.com/vovinet/infra-ft-cloud) с описанием инфраструктуры.
 - управление инфраструктурой реализовано посредством [terraform cloud](https://app.terraform.io/app/vovinet-netology/workspaces)
 - настроено автоматическое планирование и применение изменений по коммиту в репозиторий.
 - 

Скриншоты Terrafom Cloud:
![pic1-1](img/1-1.png)
![pic1-2](img/1-2.png)

Скриншот Yandex.Cloud:
![pic1-3](img/1-3.png)

Успешный статус таже видно в [репозитории](https://github.com/vovinet/infra-ft-cloud) на GitHub.

Работа с облаком производится посредством создания сервисной учётно записи c ролью compute.admin, создание keyfile и назначение на калог для размещения ресурсов:
yc iam key create --service-account-name stage-sa

Обновить IAM-токен (действует до 12 часов): ```yc iam create-token```

Полученный токен используется Terrafom Cloud с помощью Variables Set
![pic1-4](img/1-4.png)

Работаю с одним окружением, т.к. упираюсь в лимиты:
```
ResourceExhausted desc = Quota limit vpc.externalStaticAddresses.count exceeded
```

  
### 2. Создание Kubernetes кластера

 - Kubernetes-кластер развернут с помощью [kubespray](https://github.com/kubernetes-sigs/kubespray). Использованные [инвентари](conf/kubespray/)

 ```
 PLAY RECAP **************************************************************************************************************************************************************************************************
cp1                        : ok=748  changed=142  unreachable=0    failed=0    skipped=1247 rescued=0    ignored=9   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=474  changed=87   unreachable=0    failed=0    skipped=729  rescued=0    ignored=2   
node2                      : ok=474  changed=87   unreachable=0    failed=0    skipped=729  rescued=0    ignored=2   
node3                      : ok=474  changed=87   unreachable=0    failed=0    skipped=729  rescued=0    ignored=2   

Понедельник 25 июля 2022  16:27:56 +0300 (0:00:00.106)       0:17:00.223 ****** 
=============================================================================== 
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------------------------------------------------------------------------- 36.75s
kubernetes/kubeadm : Join to cluster ---------------------------------------------------------------------------------------------------------------------------------------------------------------- 34.06s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running --------------------------------------------------------------------------------------------------------------------------- 31.65s
kubernetes/control-plane : kubeadm | Initialize first master ---------------------------------------------------------------------------------------------------------------------------------------- 29.46s
download : download_file | Validate mirrors --------------------------------------------------------------------------------------------------------------------------------------------------------- 26.54s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ----------------------------------------------------------------------------------------------------------------------------------------- 16.37s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------ 15.18s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ------------------------------------------------------------------------------------------------------------------------------ 14.53s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------ 14.00s
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------------------------------------------------------------------------------------ 13.91s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------ 12.77s
kubernetes/preinstall : Update package management cache (APT) --------------------------------------------------------------------------------------------------------------------------------------- 11.55s
network_plugin/calico : Calico | Create calico manifests --------------------------------------------------------------------------------------------------------------------------------------------- 8.55s
network_plugin/calico : Start Calico resources ------------------------------------------------------------------------------------------------------------------------------------------------------- 8.54s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 8.48s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 8.11s
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 8.08s
container-engine/containerd : containerd | Unpack containerd archive --------------------------------------------------------------------------------------------------------------------------------- 7.02s
etcd : reload etcd ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 6.06s
etcd : Configure | Check if etcd cluster is healthy -------------------------------------------------------------------------------------------------------------------------------------------------- 5.92s

```

После копирования и редиктирования конфига подключимся к кластеру с локальной машины:
```
zubarev_va@A000995:~/git/kubespray$ kubectl cluster-info 
Kubernetes control plane is running at https://51.250.90.108:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
zubarev_va@A000995:~/git/kubespray$ kubectl get po -A -o wide
NAMESPACE     NAME                              READY   STATUS    RESTARTS        AGE   IP             NODE    NOMINATED NODE   READINESS GATES
kube-system   calico-node-75jww                 1/1     Running   0               11m   10.0.0.13      node3   <none>           <none>
kube-system   calico-node-ftdl8                 1/1     Running   0               11m   10.0.0.10      cp1     <none>           <none>
kube-system   calico-node-qtcqc                 1/1     Running   0               11m   10.0.0.12      node2   <none>           <none>
kube-system   calico-node-sjhws                 1/1     Running   0               11m   10.0.0.11      node1   <none>           <none>
kube-system   coredns-666959ff67-bcw84          1/1     Running   0               10m   10.233.110.1   cp1     <none>           <none>
kube-system   coredns-666959ff67-s89fc          1/1     Running   0               10m   10.233.92.1    node3   <none>           <none>
kube-system   dns-autoscaler-59b8867c86-jcddg   1/1     Running   0               10m   10.233.110.2   cp1     <none>           <none>
kube-system   kube-apiserver-cp1                1/1     Running   2 (9m16s ago)   13m   10.0.0.10      cp1     <none>           <none>
kube-system   kube-controller-manager-cp1       1/1     Running   2 (9m5s ago)    13m   10.0.0.10      cp1     <none>           <none>
kube-system   kube-proxy-8q2gt                  1/1     Running   0               13m   10.0.0.10      cp1     <none>           <none>
kube-system   kube-proxy-mdfx7                  1/1     Running   0               12m   10.0.0.13      node3   <none>           <none>
kube-system   kube-proxy-rbkdx                  1/1     Running   0               12m   10.0.0.12      node2   <none>           <none>
kube-system   kube-proxy-sb5pq                  1/1     Running   0               12m   10.0.0.11      node1   <none>           <none>
kube-system   kube-scheduler-cp1                1/1     Running   2 (9m7s ago)    13m   10.0.0.10      cp1     <none>           <none>
kube-system   nodelocaldns-7tmt4                1/1     Running   0               10m   10.0.0.11      node1   <none>           <none>
kube-system   nodelocaldns-gppsc                1/1     Running   0               10m   10.0.0.12      node2   <none>           <none>
kube-system   nodelocaldns-rb4gv                1/1     Running   0               10m   10.0.0.10      cp1     <none>           <none>
kube-system   nodelocaldns-zv27l                1/1     Running   0               10m   10.0.0.13      node3   <none>           <none>
```

### 3. Создание тестового приложения

В качестве тестового приложения был выбран nginx, отдающий тестовую страницу. Репозиторий с Dockerfile, конфигом, отдаваемым контентом и пайплайном ci доступны в [репозитории](https://gitlab.com/vovinet/docker-app)  
Скриншот репозитория, на нём также видно отметку об успешной сборке.
![pic3-1](img/3-1.png)

Реестр контейнеров:
```
https://gitlab.com/vovinet/docker-app/container_registry/
```
![pic3-2](img/3-2.png)

### 4. Подготовка cистемы мониторинга и деплой приложения

4.1. Развертывание системы мониторинга

Клонируем репозиторий
```
$ git clone git@github.com:prometheus-operator/kube-prometheus.git 
```

Переходим в склонированный каталог и развертываем контейнеры:
```
$ kubectl apply --server-side -f manifests/setup
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
namespace/monitoring serverside-applied
$ until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
No resources found
$ kubectl apply -f manifests/
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
networkpolicy.networking.k8s.io/prometheus-operator created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
service/prometheus-operator created
serviceaccount/prometheus-operator created
servicemonitor.monitoring.coreos.com/prometheus-operator created
$ kubectl get po -n monitoring -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
alertmanager-main-0                    2/2     Running   0          3m7s    10.233.90.8   node1    <none>           <none>
alertmanager-main-1                    2/2     Running   0          3m7s    10.233.90.9   node1    <none>           <none>
alertmanager-main-2                    0/2     Pending   0          3m7s    <none>        <none>   <none>           <none>
blackbox-exporter-5fb779998c-28gtf     3/3     Running   0          3m57s   10.233.90.2   node1    <none>           <none>
grafana-cd8b59df4-zkr8p                1/1     Running   0          3m51s   10.233.90.3   node1    <none>           <none>
kube-state-metrics-98bdf47b9-drn4z     3/3     Running   0          3m50s   10.233.90.4   node1    <none>           <none>
node-exporter-c8wwr                    2/2     Running   0          3m49s   10.0.0.10     cp1      <none>           <none>
node-exporter-wwf8f                    2/2     Running   0          3m48s   10.0.0.11     node1    <none>           <none>
prometheus-adapter-5f68766c85-9vvfl    1/1     Running   0          3m46s   10.233.90.5   node1    <none>           <none>
prometheus-adapter-5f68766c85-kfgwm    1/1     Running   0          3m46s   10.233.90.6   node1    <none>           <none>
prometheus-k8s-0                       0/2     Pending   0          3m6s    <none>        <none>   <none>           <none>
prometheus-k8s-1                       0/2     Pending   0          3m6s    <none>        <none>   <none>           <none>
prometheus-operator-6486d45dc7-bhqqd   2/2     Running   0          3m45s   10.233.90.7   node1    <none>           <none>
```

Проверим доступность Grafana с помощью port-forward:
```
$ POD=$(kubectl get pods --namespace=monitoring | grep grafana| cut -d ' ' -f 1)
$ kubectl port-forward $POD --namespace=monitoring 3000:3000
```
Стандартный логин пароль — admin / admin, затем пароль изменен на текущее название группы
![pic4-1](img/4-1.png)

### 5. Установка и настройка CI/CD

Создаём Namespace'ы:
```
$ kubectl create namespace stage
namespace/stage created
$ kubectl create namespace prod
namespace/prod created

```

Добавляем регистр образов:
kubectl create secret docker-registry regcred --docker-server=registry.gitlab.com --docker-username=k8s --docker-password=glpat-JVFqQnJ4edyoSAtZsi3z

Приложение упаковано в qbec, манифесты расположены в [каталоге](deploy/)