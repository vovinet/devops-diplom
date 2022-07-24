
// this file has the baseline default parameters
{
  components: {
    myapp: {
      name: 'myapp',
      image: 'registry.gitlab.com/vovinet/docker-app:latest',
      replicas: 1,
      containerPort: 80,
      servicePort: 80,
      nodeSelector: {},
      tolerations: [],
      ingressClass: 'nginx',
      domain: 'myapp.zubarev.su',
    },
  },
}
