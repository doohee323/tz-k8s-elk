# tz-k8s-elk

It installs ELK on k8s in local VMs. It use Helm3, but using the official guides for Elasticsearch, it doesn't work.

## -. Issues
```
  -. It requires too much resources in local VMs in Vagrant env.
  -. It requires a storage but there is no guide.
  -. It's ELK readinessProbe doesn't work in local env.

```

## -. Features 
```
  -. build a vagrant env
  -. install k8s master and nodes
  -. install dashboard
  -. install monitoring (Prometheus, Grafana)
```

## -. Run
``` 
  vagrant up
  vagrant destroy -f

  vagrant ssh k8s-master

  bash /vagrant/tz-local/resource/elk/install.sh

  vagrant restore

  vagrant snapshot save k8s-master k8s-master_filebeat
  vagrant snapshot save node-1 node-1_filebeat
  vagrant snapshot save node-1 node-1_filebeat

  vagrant snapshot restore k8s-master k8s-master_filebeat
  vagrant snapshot restore node-1 node-1_filebeat
  vagrant snapshot restore node-1 node-1_filebeat
``` 

## -. Verify
``` 
  vagrant ssh k8s-master

  k get all

  to set pod/elasticsearch-master-* valid,

  bash /vagrant/tz-local/resource/elk/fix.sh
``` 




