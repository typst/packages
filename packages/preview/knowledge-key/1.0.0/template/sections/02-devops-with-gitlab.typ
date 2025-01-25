#import "../utils.typ": *

= DevOps with Gitlab
#sourcecode[```yaml
default:
  image: alpine:3.19.1
------
rules:
  - if: $CI_COMMIT_BRANCH == "main"
rules:
  - changes:
    - README.md
```]

== Automated application deployment
=== Declaring deployment environments
Environments in Gitlab define where code gets deployed.
It allows to see a history of deployments and allows to rollback to earlier version.

#sourcecode[```yaml
deploy:
  stage: deploy
  environment:
    name: production
    url: https://example.com
```]

=== Kubernetes application resources
You can build images and push them into your Gitlab container registry.
Passing the Kubernetes YAML into `envsubst`, you can replace the environment variable with the actual value.

=== Deploying an application to Kubernetes
Using the Gitlab Kubernetes integration, you can easily deploy your application to Kubernetes.
- You can define multiple Kubernetes cluster to connect to and then define via “environment
scope” which environment corresponds to which Kubernetes cluster
- The Kubernetes cluster credentials are available to any job.

=== Deploy tokens and pulling secrets
We need Kubernetes authentication information so it can pull the Docker image from our Gitlab registry.
Gitlab has a feature named “deploy tokens” that can be defined per project and have a defined scope like “read_registry”.

Then you expose the deploy token with environment variables to the build environment.

In Kubernetes, you can create a secret with the type “docker-registry” and pass the deploy token
to it.

#sourcecode[```yaml
deploy:
  stage: deploy
  environment:
    name: production
    url: http://todo.deploy.k8s.anvard.org
  image: roffe/kubectl:v1.13.0
  script:
    - kubectl delete --ignore-not-found=true secret gitlab-auth
    - kubectl create secret docker-registry gitlab-auth --docker-server=$CI_REGISTRY --docker-username=$KUBE_PULL_USER --docker-password=$KUBE_PULL_PASS
    - cat k8s.yaml | envsubst | kubectl apply -f –
```]

And then reference the secret from your k8s.yaml.

#sourcecode[```yaml
spec:
  replica: 3
  selector:
    matchLabels:
      app: todo
  template:
    metadata:
      labels:
        app: app
    spec:
      imagePullSecrets:
        - name: gitlab-auth
      containers:
        - name: todo
          image: "${DOCKER_IMAGE_TAG}"
          env:
            - name: NODE_ENV
              value: "production"
            - name: DATABASE_URL
              value: "postgres://${DBUSER}:${DBPASS}@tododb/todo"
          ports:
            - containerPort: 3000
```]

=== Dynamic environments and review apps
Idea: Have a separate deployment for each branch for the devs to fiddle around with. (`todo-${DEPLOY_SUFFIX}`)
This can be achived by adding a DEPLOY_SUFFIX and DEPLOY_HOST to all k8s resources.
Another job is added that deletes the resources when the branch is deleted.
This job can be triggered with `on:stop: job_name` in the environment section.

== Application quality and monitoring
=== Integration and functional testing
To run integration tests, you can define services per Gitlab job, e.g., a Postgres database container.
A service is an extra container that GitLab CI will run for us as part of our build or test process.
The extra container is going to be available to the mail container.

#sourcecode[```yaml
test-10:
  stage: test
  image: node:10
  services:
    - name: postgres:10
      alias: db
  variables:
    POSTGRES_DB: todo
    POSTGRES_USER: "${DBUSER}"
    POSTGRES_PASS: "${DBPASS}"
    DATABASE_URL: "postgres://${DBUSER}:${DBPASS}@db/todo"
  script:
    - ./ci-test.sh
```]
This service will be reachable as “db” from our job script.

=== Analyze code quality
Gitlab offers automated code quality checks which can run with each pipeline.
The result of the analysis will be displayed alongside the merge request.
Code quality jobs usually take quite a bit of time.
(`include: (pagebreak) - template: Code-Quality.gitlab-ci.yaml`)

=== Dynamic application security testing (DAST)
Gitlab can check an application “from outside” for security issues.

=== Application monitoring with Prometheus
Prometheus identifies metric endpoints from an application and scrapes periodically metrics from those endpoints.
If the Kubernetes integration with Gitlab is activated, Gitlab will deploy a Prometheus server to said cluster.
To define that your service has endpoints to get data from for Prometheus, you need to add annotations to the Kubernetes service. (In the kubernetes Service file)

The data can be reviewed in Gitlab directly.
Spaceships are added to the timeline to indicate when a deployment happened.

== Custom CI infrastructure
=== Launching dedicated runners
When using gitlab.com, your jobs are running on shared infrastructure.
You can also launch dedicated runners for your project and connect them to gitlab.com.
Below is the configuration page and an overview of runners assigned to the project.

When launching dedicated runners, you can assign them tags.
In your pipeline definition, you can force to run the job on dedicated runners by also mentioning the tags used for dedicated runners in the pipeline.

There is different type of runners:
- Shell: Run builds directly on runner host. Useful for building virtual machine or Docker
images.
- Docker: Run builds in Docker containers. Can be used for building Docker images through “Docker in Docker” configuration.
- Docker machine: Launches virtual machines to run builds in Docker. Useful for autoscaling.
- Kubernetes: Runs builds in Docker containers inside Kubernetes. Useful to consolidate build infrastructure when using Kubernetes.

=== Custom Kubernetes runners
You can also deploy Gitlab runners from Gitlab to a Kubernetes cluster.