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

  vagrant snapshot save k8s-master k8s-master_1
  vagrant snapshot save node-1 node-1_1
  vagrant snapshot save node-1 node-1_1
``` 

## -. Verify
``` 
  vagrant ssh k8s-master

  k get all

  to set pod/elasticsearch-master-* valid,

  bash /vagrant/tz-local/resource/elk/fix.sh
``` 




