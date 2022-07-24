
local p = import '../params.libsonnet';
local params = p.components.hello;

[
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'myapp-config',
    },
    data: {
      'index.html': params.indexData,
    },
  },

  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'myapp-config',
    },
    data: {
      'index.html': params.indexData,
    },
  },

  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'myapp-deploy',
      labels: {
        app: 'myapp-deploy',
      },
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: 'myapp-deploy',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'myapp-deploy',
          },
        },
        spec: {
          containers: [
            {
              name: 'main',
              image: 'nginx:stable',
              imagePullPolicy: 'Always',
              volumeMounts: [
                {
                  name: 'web',
                  mountPath: '/usr/share/nginx/html',
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'web',
              configMap: {
                name: 'myapp-config',
              },
            },
          ],
        },
      },
    },
  },
]
