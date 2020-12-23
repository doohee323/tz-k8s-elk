#!/usr/bin/env bash

#set -x

#INC_CNT=0
#TARGET_CNT=2
#MAX_CNT=50
#while true; do
#  sleep 10
#  INST_CNT=`k get nodes | grep Ready | wc | awk '{print $1}'`
#  if [[ $INST_CNT == $TARGET_CNT || $INC_CNT == $MAX_CNT ]]; then
#    break
#  fi
#  let "INC_CNT=INC_CNT+1"
#done

sudo chown -Rf vagrant:vagrant /var/run/docker.sock

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

sleep 10

helm repo add stable https://charts.helm.sh/stable
helm repo update

#k get po -n kube-system

#export HELM_HOST=localhost:44134

sudo rm -Rf /vagrant/info

exit 0

##################################################################
# call es install script
##################################################################
#bash /vagrant/tz-local/resource/elk/install.sh

##################################################################
# call dashboard install script
##################################################################
#bash /vagrant/tz-local/resource/dashboard/install.sh

##################################################################
# call monitoring install script
##################################################################
#bash /vagrant/tz-local/resource/monitoring/install.sh

exit 0

vagrant snapshot save k8s-master k8s-master_init --force
vagrant snapshot save node-1 node-1_init --force
vagrant snapshot save node-2 node-2_init --force

vagrant snapshot restore k8s-master k8s-master_init
vagrant snapshot restore node-1 node-1_init
vagrant snapshot restore node-2 node-2_init

vagrant snapshot save k8s-master k8s-master_es --force
vagrant snapshot save node-1 node-1_es --force
vagrant snapshot save node-2 node-2_es --force

vagrant snapshot save k8s-master k8s-master_elk --force
vagrant snapshot save node-1 node-1_elk --force
vagrant snapshot save node-2 node-2_elk --force





