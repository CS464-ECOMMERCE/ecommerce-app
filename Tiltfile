# namespace plugin
load('ext://namespace', 'namespace_inject', 'namespace_create')

# helm plugin
# load('ext://helm_resource', 'helm_resource', 'helm_repo')

namespace = "ecommerce"

modules = [
  {
      "image_repo": "backend",
      "chart_repo": "backend-chart",
      "values":  "dev.values.yaml" ,
  },
  {
      "image_repo": "product",
      "chart_repo": "product-chart",
      "values":  "dev.values.yaml" ,
  },{
      "image_repo": "cart",
      "chart_repo": "cart-chart",
      "values":  "dev.values.yaml" ,
  },{
    "image_repo": "order",
    "chart_repo": "order-chart",
    "values":  "dev.values.yaml" ,
  }
]

# create the namespace
namespace_create(namespace)

# deploy secrets first
k8s_yaml(namespace_inject(read_file("./secrets.yml"), namespace))


# deploy mongodb and rabbitmq
k8s_yaml(namespace_inject(helm("./k8s/postgresql-chart/helm/", name="postgres", values="./k8s/postgresql-chart/helm/dev.values.yaml"), namespace ), allow_duplicates=False)

# create redis
k8s_yaml(namespace_inject(helm("./k8s/redis-chart/helm/", name="redis", values='./k8s/redis-chart/helm/dev.values.yaml'), namespace), allow_duplicates=False)
# k8s_yaml(namespace_inject(helm("./k8s/rabbitmq-charts/helm/", name="rabbitmq"), namespace ), allow_duplicates=False)

# for each module
for m in modules:
#   image_tag = registry + '/' + m["image_repo"] + '/main'
  context = './' + m["image_repo"]
  dockerfile = './' + m["image_repo"] + '/docker/Dockerfile.dev'
  chart = 'k8s/' + m["chart_repo"] + '/helm/'
  values = chart + m['values']

#   build it
  docker_build(
  m["image_repo"], 
  context,
  dockerfile=dockerfile,
  live_update=[
    sync('./' + m["image_repo"], '/app')
  ], 
  extra_tag=["latest"])

  # and deploy it with helm
  k8s_yaml(namespace_inject(helm(chart, name=m["image_repo"], values=values), namespace), allow_duplicates=False)

# create s3
# helm_repo('minio-operator', 'https://operator.min.io')
# helm_resource('operator', 'minio-operator/minio-operator', resource_deps=['minio-operator'])



# create traefik last
k8s_yaml(namespace_inject(helm("./k8s/traefik-chart/helm/", name="traefik", values='./k8s/traefik-chart/helm/dev.values.yaml'), namespace), allow_duplicates=False)
