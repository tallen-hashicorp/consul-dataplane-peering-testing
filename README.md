# consul-dataplane-peering-testing
Testing out Consul enterprise Dataplane and Cluster Peering. For this testing I will be using a local K8s to simulate seperated consul architecuture however eveything here should work on VM's.

# Consul Standalone
This section we will install consul into a k8s cluster simulating 3 VMS running consul

## Create Consul Licence Secret
All of the following examples use consul enterprise, we will need to create a secret containing the licence key. Create a new file called `consul.hclic` containing your consul licence
```bash
kubectl create ns consul-dc1
kubectl create secret generic consul-ent-license --namespace=consul-dc1 --from-file=key=consul.hclic
```

## Generate the gossip encryption key
Gossip is encrypted with a symmetric key, since gossip between nodes is done over UDP. All agents must have the same encryption key. This step assumes you have consul installed on your local machine.

```bash
kubectl create secret generic consul-gossip-key --namespace consul-dc1 --from-literal=key="$(consul keygen)"
```

## Generate certificates for RPC encryption
Consul can use TLS to verify the authenticity of servers and clients. To enable TLS, Consul requires that all agents have certificates signed by a single Certificate Authority (CA). This step assumes you have consul installed on your local machine.

Start by creating the CA on your admin instance, using the Consul CLI.

```bash
consul tls cert create -server -dc dc1 -domain consul
kubectl create secret generic consul-certs --namespace consul-dc1 \
  --from-file=consul-agent-ca-key.pem=consul-agent-ca-key.pem \
  --from-file=consul-agent-ca.pem=consul-agent-ca.pem \
  --from-file=dc1-server-consul-0.pem=dc1-server-consul-0.pem \
  --from-file=dc1-server-consul-0-key.pem=dc1-server-consul-0-key.pem
```

## Deploy consul
```bash
kubectl apply -n consul-dc1 -f standalone
```

## Access Consul
```bash
kubectl -n consul-dc1 port-forward services/consul-http 8500:8500
```

## Delete the deployment
```bash
kubectl delete -n consul-dc1 -f standalone
```


# Consul Dataplane
This topic provides an overview of Consul Dataplane, a lightweight process for managing Envoy proxies. Consul Dataplane removes the need to run client agents on every node in a cluster for service discovery and service mesh. Instead, Consul deploys sidecar proxies that provide lower latency, support additional runtimes, and integrate with cloud infrastructure providers.

When deployed to virtual machines or bare metal environments, the Consul control plane requires server agents and client agents. Server agents maintain the service catalog and service mesh, including its security and consistency, while client agents manage communications between service instances, their sidecar proxies, and the servers. While this model is optimal for applications deployed on virtual machines or bare metal servers, orchestrators such as Kubernetes and ECS have native components that support health checking and service location functions typically provided by the client agent.

Consul Dataplane manages Envoy proxies and leaves responsibility for other functions to the orchestrator. As a result, it removes the need to run client agents on every node. In addition, services no longer need to be reregistered to a local client agent after restarting a service instance, as a client agent’s lack of access to persistent data storage in container-orchestrated deployments is no longer an issue.

The following diagram shows how Consul Dataplanes facilitate service mesh in a Kubernetes-orchestrated environment.

![Consul Dataplane](./docs/assets.avif)
