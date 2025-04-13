# namespace plugin
load('ext://namespace', 'namespace_inject', 'namespace_create')

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

chart_repo = "./k8s"

# deploy postgresql
k8s_yaml(namespace_inject(helm(chart_repo + "/postgresql-chart/helm/", name="postgres", values=chart_repo + "/postgresql-chart/helm/dev.values.yaml"), namespace), allow_duplicates=False)

# create redis
k8s_yaml(namespace_inject(helm(chart_repo + "/redis-chart/helm/", name="redis", values=chart_repo + '/redis-chart/helm/dev.values.yaml'), namespace), allow_duplicates=False)

# for each module
for m in modules:
  context = './' + m["image_repo"]
  dockerfile = './' + m["image_repo"] + '/docker/Dockerfile.dev'
  chart = 'k8s/' + m["chart_repo"] + '/helm/'
  values = chart + m['values']

  # build docker image
  docker_build(
    m["image_repo"], 
    context,
    dockerfile=dockerfile,
    live_update=[
      sync('./' + m["image_repo"], '/app')
    ], 
    extra_tag=["latest"]
  )

  # and deploy it with helm
  k8s_yaml(namespace_inject(helm(chart, name=m["image_repo"], values=values), namespace), allow_duplicates=False)

# create s3
# helm_repo('minio-operator', 'https://operator.min.io')
# helm_resource('operator', 'minio-operator/minio-operator', resource_deps=['minio-operator'])

# create traefik last
k8s_yaml(namespace_inject(helm(chart_repo + "/traefik-chart/helm/", name="traefik", values=chart_repo + '/traefik-chart/helm/dev.values.yaml'), namespace), allow_duplicates=False)
