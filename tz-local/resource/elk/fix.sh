#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

## *** fix readiness issue
#k get pod/elasticsearch-master-0 -o yaml > /vagrant/tz-local/resource/elk/elasticsearch-master-0.yaml
k exec -it pod/elasticsearch-master-0 -- sh -c "/usr/bin/touch /tmp/.es_start_file"
k exec -it pod/elasticsearch-master-1 -- sh -c "/usr/bin/touch /tmp/.es_start_file"

exit 0
