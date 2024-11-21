def call() {
    return """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.8.5-jdk-11
    command: ['cat']
    tty: true
"""
}