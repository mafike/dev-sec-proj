############### opa-k8s-security.rego ############### 
package main

deny[msg] {
  input.kind = "Service"
  not input.spec.type = "LoadBalancer"
  msg = "Service type should be LoadBalancer"
}

deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
  msg = "Containers must not run as root - use runAsNonRoot wihin container security context"
}

############### opa-k8s-security.rego ############### 