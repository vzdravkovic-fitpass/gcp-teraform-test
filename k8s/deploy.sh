# 1. First, create the shared volume
kubectl apply -f fitpass-shared-volume.yaml

# 2. Then deploy the services (Redis can be deployed anytime)
helm install fitpass-redis ./fitpass-redis/
helm install fitpass-platform ./fitpass-platform/
helm install fitpass-nginx ./fitpass-nginx/