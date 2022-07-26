
local p = import '../params.libsonnet';
local params = p.components.myapp;

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: params.name,
    },
    spec: 
    {
      ports: [
        {
          name: 'web',
          targetPort: params.servicePort,
          port: 80,
        },
      ],
      selector: {
        app: params.name
      },
    }
  },

  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: params.name,
      labels: {
        app: params.name,
      },
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: params.name,
          },
        },
        spec: {
          containers: [
            {
              name: 'myapp',
              image: params.image + ':' + params.imageTag,
              imagePullPolicy: 'Always',
              imagePullSecrets: [
                { 
                  name: 'gitlab-secret',
                },
              ],
   
              ports: [
              {
                containerPort: params.containerPort,
                protocol: 'TCP'
              },
              ],
            },
          ],
        },
      },
    },
  },
]
