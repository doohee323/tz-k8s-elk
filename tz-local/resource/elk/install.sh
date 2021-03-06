#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

## *** fix storage issue
rm -Rf /vagrant/es/index0
rm -Rf /vagrant/es/index1
rm -Rf /vagrant/es/index2
mkdir -p /vagrant/es/index0
mkdir -p /vagrant/es/index1
mkdir -p /vagrant/es/index2

mkdir -p /vagrant/data

helm uninstall elasticsearch
k delete pvc elasticsearch-master-elasticsearch-master-0
k delete pvc elasticsearch-master-elasticsearch-master-1
k get pvc
k get pv

helm repo add elastic https://helm.elastic.co
helm search hub elasticsearch
helm repo update
helm install elasticsearch --version 7.8.0 elastic/elasticsearch

k delete -f /vagrant/tz-local/resource/elk/storage-local.yaml
k apply -f /vagrant/tz-local/resource/elk/storage-local.yaml

k delete -f /vagrant/tz-local/resource/elk/tz-py-crawler-pv.yaml
k apply -f /vagrant/tz-local/resource/elk/tz-py-crawler-pv.yaml

sleep 10
## *** fix size & resource issue
k get statefulset.apps/elasticsearch-master -o yaml > /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|Filesystem|Filesystem\n      storageClassName: local-storage0|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|30Gi|3Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
#sudo sed -i "s|2Gi|3Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|replicas: 3|replicas: 2|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
k delete -f /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml

sleep 120

k get all

helm uninstall filebeat
helm install filebeat elastic/filebeat
sleep 10
k get daemonset.apps/filebeat-filebeat -o yaml > /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml
k delete -f /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml
sudo sed -i "s|filebeat test output|curl --fail http://elasticsearch-master:9200|g" /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml
sudo sed -i "s|dnsPolicy: ClusterFirst|  - mountPath: /mnt\n          name: local-persistent-storage\n      dnsPolicy: ClusterFirst|g" /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml
sudo sed -i "s|  updateStrategy:|      - name: local-persistent-storage\n        persistentVolumeClaim:\n          claimName: tz-pvc\n  updateStrategy:|g" /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml

# add a new filebeat config
#k get configmap filebeat-filebeat-config -o yaml > /vagrant/tz-local/resource/elk/filebeat-filebeat-config.yaml
k delete configmap filebeat-filebeat-config
k apply -f /vagrant/tz-local/resource/elk/filebeat-filebeat-config.yaml
k delete -f /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml
k apply -f /vagrant/tz-local/resource/elk/filebeat-filebeat-daemonset.yaml

sleep 30

helm uninstall kibana
helm install kibana --version 7.8.0 elastic/kibana
slee 30
# to avoid "0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate."
k taint nodes --all node-role.kubernetes.io/master-

sleep 120
#k logs -f pod/kibana-kibana-7df6b6c4c-k2ksg

## change service type
#k get service/elasticsearch-master -o yaml > /vagrant/tz-local/resource/elk/elasticsearch-master-service.yaml
k delete service/elasticsearch-master
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-service.yaml
#k port-forward svc/elasticsearch-master 31200:9200
curl http://localhost:31200
curl http://192.168.2.10:31200

# k exec -it pod/elasticsearch-master-0 -- sh

k delete service/kibana-kibana
k apply -f /vagrant/tz-local/resource/elk/kibana-service.yaml
#k port-forward svc/kibana-kibana 30601:5601
curl http://localhost:30601
curl http://192.168.2.10:30601

echo '
##[ ES ]##########################################################
- Url: http://192.168.2.10:30601

#  bash /vagrant/tz-local/resource/elk/fix.sh
#######################################################################
' >> /vagrant/info
cat /vagrant/info

exit 0

## *** fix readiness issue
#k get pod/elasticsearch-master-0 -o yaml > /vagrant/tz-local/resource/elk/elasticsearch-master-0.yaml
k exec -it pod/elasticsearch-master-0 -- sh -c "/usr/bin/touch /tmp/.es_start_file"
k exec -it pod/elasticsearch-master-1 -- sh -c "/usr/bin/touch /tmp/.es_start_file"

http://dhong@dhong323:30601


k exec -it pod/filebeat-filebeat-4msfp -- sh
vi /mnt/config/filebeat.yml
