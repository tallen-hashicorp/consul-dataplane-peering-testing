#!/bin/bash

echo "Creating namespace: consul-dc1"
kubectl create ns consul-dc1

echo "Creating Consul Enterprise license secret"
kubectl create secret generic consul-ent-license --namespace=consul-dc1 --from-file=key=consul.hclic

echo "Creating Consul gossip key secret"
kubectl create secret generic consul-gossip-key --namespace consul-dc1 --from-literal=key="$(consul keygen)"

echo "Creating Consul TLS certificates"
consul tls ca create
consul tls cert create -server -dc dc1 -domain consul

echo "Creating Consul certificates secret"
kubectl create secret generic consul-certs --namespace consul-dc1 \
  --from-file=consul-agent-ca-key.pem=consul-agent-ca-key.pem \
  --from-file=consul-agent-ca.pem=consul-agent-ca.pem \
  --from-file=dc1-server-consul-0.pem=dc1-server-consul-0.pem \
  --from-file=dc1-server-consul-0-key.pem=dc1-server-consul-0-key.pem

echo "Applying standalone Consul configuration"
kubectl apply -n consul-dc1 -f standalone
