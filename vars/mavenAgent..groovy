def call() {
    return """
apiVersion: v1
kind: Pod
metadata:
  label: shared-agent
spec:
  containers:
  - name: maven
    image: maven:3.8.5-jdk-11
    command: ['cat']
    tty: true
  - name: docker
    image: docker:20.10
    command: ['cat']
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
  - name: utility
    image: busybox
    command: ['cat']
    tty: true
}
