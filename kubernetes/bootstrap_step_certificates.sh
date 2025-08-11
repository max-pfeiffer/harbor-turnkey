#!/bin/bash

step ca init \
  --name "Harbor" \
  --dns "step-certificates.security.svc.cluster.local" \
  --address ":9000" \
  --provisioner "cert-manager" \
  --deployment-type standalone \
  --helm \
  > helm_values/step-certificates-bootstrap.yaml