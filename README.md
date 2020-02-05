# Loadbalancers

Inspur Cloud Controller Manager runs service controller,
which is responsible for watching services of type ```LoadBalancer```
and creating Inspur loadbalancers to satisfy its requirements.
Here are some examples of how it's used.

**step1:**

To create a load balancing SLD by testing users, you need to create it on the load balancing product page. For example, the production line is https://console1.cloud.inspur.com/slb/#/slb?region=cn-north-3

**step2:**

create service,type is loadbalancer

_**External HTTP loadbalancer**_

When you create a service with ```type: LoadBalancer```, an Inspur load balancer will be created.
The example below will create a nginx deployment and expose it via an Inspur External load balancer.

_**yaml**_

See svc.yaml and deployment.yaml in the test directory for details

---

The ```service.beta.kubernetes.io/inspur-load-balancer-slbid``` annotation
is used on the service to indicate the loadbalancer id we want to use.

The ```loadbalancer.inspur.com/forward-rule``` annotation
indicates which forwardRule we want to use,such as WRR,RR 

The ```loadbalancer.inspur.com/is-healthcheck``` default is false.
it means Whether to turn on health check.


```bash
$ kubectl create -f examples/loadbalancers/external-http-nginx.yaml
```

Watch the service and await an ```EXTERNAL-IP``` by the following command.
This will be the load balancer IP which you can use to connect to your service.

```bash
$ watch kubectl get service
NAME                 CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
http-nginx-service   10.0.0.10      122.112.219.229   80:30000/TCP   5m
```

**step3:**

You can now access your service via the provisioned load balancer.

```bash
$ curl http://122.112.219.229
```

You can also view it on the loadbalancer page
