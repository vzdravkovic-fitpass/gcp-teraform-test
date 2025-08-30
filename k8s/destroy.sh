helm uninstall fitpass-redis
helm uninstall fitpass-platform
helm uninstall fitpass-nginx

kubectl delete pvc fitpass-app-storage-claim
kubectl delete pv fitpass-app-storage-pv