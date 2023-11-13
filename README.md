# consul-dataplane-peering-testing
Testing out Consul Dataplane and Cluster Peering. For this testing I will be using a local K8s to simulate seperated consul architecuture

# Consul Dataplane
This topic provides an overview of Consul Dataplane, a lightweight process for managing Envoy proxies. Consul Dataplane removes the need to run client agents on every node in a cluster for service discovery and service mesh. Instead, Consul deploys sidecar proxies that provide lower latency, support additional runtimes, and integrate with cloud infrastructure providers.

![Consul Dataplane](./docs/assets.avif)