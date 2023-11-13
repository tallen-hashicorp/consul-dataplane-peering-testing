# consul-dataplane-peering-testing

Testing out Consul enterprise Dataplane and Cluster Peering. For this testing, I will be using a local K8s to simulate separated consul architecture; however, everything here should work on VMs.

## Consul Standalone

This section installs Consul into a K8s cluster simulating 3 VMs running Consul.

### Create Consul License Secret

All of the following examples use Consul enterprise; we need to create a secret containing the license key. Create a new file called `consul.hclic` containing your Consul license.

```bash
kubectl create ns consul-dc1
kubectl create secret generic consul-ent-license --namespace=consul-dc1 --from-file=key=consul.hclic
```

### Generate the gossip encryption key

Gossip is encrypted with a symmetric key since gossip between nodes is done over UDP. All agents must have the same encryption key. This step assumes you have Consul installed on your local machine.

```bash
kubectl create secret generic consul-gossip-key --namespace consul-dc1 --from-literal=key="$(consul keygen)"
```

### Generate certificates for RPC encryption

Consul can use TLS to verify the authenticity of servers and clients. To enable TLS, Consul requires that all agents have certificates signed by a single Certificate Authority (CA). This step assumes you have Consul installed on your local machine.

Start by creating the CA on your admin instance, using the Consul CLI.

```bash
consul tls ca create
consul tls cert create -server -dc dc1 -domain consul
kubectl create secret generic consul-certs --namespace consul-dc1 \
  --from-file=consul-agent-ca-key.pem=consul-agent-ca-key.pem \
  --from-file=consul-agent-ca.pem=consul-agent-ca.pem \
  --from-file=dc1-server-consul-0.pem=dc1-server-consul-0.pem \
  --from-file=dc1-server-consul-0-key.pem=dc1-server-consul-0-key.pem
```

### Deploy Consul

```bash
kubectl apply -n consul-dc1 -f standalone
```

### Access Consul

```bash
kubectl -n consul-dc1 port-forward services/consul-http 8500:8500
```

### Delete the deployment

```bash
kubectl delete ns consul-dc1
```

### Quick Deploy

If you want to deploy quickly, use the following commands:

```bash
./scripts/0-standalone-dc1.sh
sleep 2
kubectl -n consul-dc1 port-forward services/consul-http 8500:8500
```

# Consul Dataplane

This topic provides an overview of Consul Dataplane, a lightweight process for managing Envoy proxies. Consul Dataplane removes the need to run client agents on every node in a cluster for service discovery and service mesh. Instead, Consul deploys sidecar proxies that provide lower latency, support additional runtimes, and integrate with cloud infrastructure providers.

When deployed to virtual machines or bare metal environments, the Consul control plane requires server agents and client agents. Server agents maintain the service catalog and service mesh, including its security and consistency, while client agents manage communications between service instances, their sidecar proxies, and the servers. While this model is optimal for applications deployed on virtual machines or bare metal servers, orchestrators such as Kubernetes and ECS have native components that support health checking and service location functions typically provided by the client agent.

Consul Dataplane manages Envoy proxies and leaves responsibility for other functions to the orchestrator. As a result, it removes the need to run client agents on every node. In addition, services no longer need to be re-registered to a local client agent after restarting a service instance, as a client agent’s lack of access to persistent data storage in container-orchestrated deployments is no longer an issue.

The following diagram shows how Consul Dataplanes facilitate service mesh in a Kubernetes-orchestrated environment.

![Consul Dataplane](./docs/assets.avif)

The Following diagram shows how Consul Dataplanes function wihtout mesh deployed

TODO


```bash
apk add tcpdump
tcpdump port 8502
```
 ./consul-dataplane -addresses=127.0.0.1 -service-node-name=fake-service-dataplane -proxy-service-id=1 -ca-certs=/Users/tyler.allen/Documents/projects/consul-dataplane-peering-testing/consul-agent-ca.pem



          - "/usr/local/bin/dumb-init"
          - "/usr/local/bin/consul-dataplane"
          - "-addresses=consul-rpc.consul-dc1.svc"
          - "-addresses=consul-serf-lan.consul-dc1.svc"
          - "-addresses=consul-grpc.consul-dc1.svc"
          - "-service-node-name=fake-service-dataplane"
          - "-proxy-service-id=1"
          - "-ca-certs=/consul/certs/consul-agent-ca.pem"
          - "-ca-certs=/consul/certs/dc1-server-consul-0.pem"
          - "-grpc-port=8502"
          - "-log-level=trace"