# 1. Проблема загрузки образа из репозитория registry.gitlab.com в kubernetes-cluster.

Сборочная линия настроена на базе gitlab-ci и готовый образ с приложением помещается в registry.gitlab.com.

Проверяем доступность образов и репозитория с локальной машины:
В качестве логина использую логин, в качестве пароля - личный токен доступа.

## Проверка на локальном АРМ

### Авторизация

```
zubarev_va@A000995:~/git/devops-diplom/deploy$ docker login registry.gitlab.com
Username: vovinet
Password: 
WARNING! Your password will be stored unencrypted in /home/zubarev_va/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

### Пробую спулить образ
```
zubarev_va@A000995:~/git/devops-diplom/deploy$ docker pull registry.gitlab.com/vovinet/docker-app
Using default tag: latest
latest: Pulling from vovinet/docker-app
2408cc74d12b: Already exists 
d2c51e4658f4: Pull complete 
62d847ae41bd: Pull complete 
2c8706ff17ca: Pull complete 
b799afd5c2c0: Pull complete 
Digest: sha256:85f284e6b19e8648e15471ebef0f5d58d93f1ac969287fb9f7efdec2bc3756b2
Status: Downloaded newer image for registry.gitlab.com/vovinet/docker-app:latest
registry.gitlab.com/vovinet/docker-app:latest

```

## Проверка на kubernetes-кластере в Yandex Cloud

При добавлении стороннего репозитория в kubernetes-кластер руководствовался (много на самом деле каких статей перепробовал) официальной [документацией](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/), а именно:
- создание секрета:
```
kubectl create secret docker-registry gitlab_secret --docker-server=registry.gitlab.com --docker-username=vovinet --docker-password=glpat-F55RbNBKXG4Mz-PzYEp6 --docker-email=v.zubarev@inbox.ru
```
назначение секрета на под:
```
kubectl apply -f question_sessions/qs1_manifests/custom_repo_image_deploy.yml
```
В итоге имеет результат:
```
zubarev_va@A000995:~/git/devops-diplom$ kubectl create secret docker-registry gitlab-secret --docker-server=registry.gitlab.com --docker-username=vovinet --docker-password=glpat-F55RbNBKXG4Mz-PzYEp6 --docker-email=v.zubarev@inbox.ru
secret/gitlab-secret created
zubarev_va@A000995:~/git/devops-diplom$ kubectl delete -f question_sessions/qs1_manifests/custom_repo_image_deploy.yml
deployment.apps "my-app-qs1" deleted
zubarev_va@A000995:~/git/devops-diplom$ kubectl apply -f question_sessions/qs1_manifests/custom_repo_image_deploy.yml
deployment.apps/my-app-qs1 created
zubarev_va@A000995:~/git/devops-diplom$ kubectl -n stage get po
NAME                     READY   STATUS             RESTARTS   AGE
myapp-7f47b686c9-s68wz   0/1     InvalidImageName   0          19h
```

Прежде я имел ошибку
```
zubarev_va@A000995:~/git/kube-prometheus$ kubectl -n stage get po
NAME                     READY   STATUS             RESTARTS   AGE
myapp-7f47b686c9-5k7rq   0/1     InvalidImageName   0          25s
```

Теперь после N итераций вообще ничего не происходит, деплоймент висит в ожидании чего-то:
```
zubarev_va@A000995:~/git/devops-diplom$ kubectl -n stage get deployments.apps 
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
my-app-qs1   0/1     0            0           37m
zubarev_va@A000995:~/git/devops-diplom$ kubectl get nodes -o wide
NAME    STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
cp1     Ready    control-plane   24h   v1.24.2   10.0.0.10     <none>        Ubuntu 20.04.3 LTS   5.4.0-42-generic   containerd://1.6.6
node1   Ready    <none>          24h   v1.24.2   10.0.0.11     <none>        Ubuntu 20.04.3 LTS   5.4.0-42-generic   containerd://1.6.6
node2   Ready    <none>          24h   v1.24.2   10.0.0.12     <none>        Ubuntu 20.04.3 LTS   5.4.0-42-generic   containerd://1.6.6
node3   Ready    <none>          24h   v1.24.2   10.0.0.13     <none>        Ubuntu 20.04.3 LTS   5.4.0-42-generic   containerd://1.6.6
zubarev_va@A000995:~/git/devops-diplom$ kubectl -n stage describe deployments.apps my-app-qs1
Name:                   my-app-qs1
Namespace:              stage
CreationTimestamp:      Tue, 26 Jul 2022 16:42:12 +0300
Labels:                 app=my-app-qs1
Annotations:            <none>
Selector:               app=my-app-qs1
Replicas:               1 desired | 0 updated | 0 total | 0 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=my-app-qs1
  Containers:
   my-app-qs1-container:
    Image:        registry.gitlab.com/vovinet/docker-app:latest
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:           <none>
zubarev_va@A000995:~/git/devops-diplom$ kubectl -n stage get po
No resources found in stage namespace.
```
пока тупик...