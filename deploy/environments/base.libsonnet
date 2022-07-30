
// this file has the baseline default parameters
{
  components: {
    myapp: {
      name: 'myapp',
      image: 'registry.gitlab.com/vovinet/docker-app',
      replicas: 1,
      imageTag: 'latest',
      targetPort: 80,
      hostPort: 8081,
      port: 8080,
      nodeSelector: {},
    },
  },
}
