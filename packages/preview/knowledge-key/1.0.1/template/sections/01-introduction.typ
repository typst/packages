#import "../utils.typ": *

= Introduction Cloud Operations and DevOps
== The DevOps pipelines
*What is DevOps?*\
DevOps team focuses on CI/CD. DevOps team would like to be continuously pushing small changes out to production, monitor what happens in production, see  he result of that and use that to make further improvements to the system.

*Plan stage*: Backlog filled, Sprint Planning\
*Code stage*: Code is written, reviewed, and merged\
*Build stage*: CI Pipeline builds code and runs tests\
*Test stage*: Deploy to test environment, run automated tests\
*Release stage*: Tag code snapshot, Document features and changes\
*Deploy stage*: Deploy to production environment, Monitor\
*Operate Stage*: Ensuring application runs smootly, troubleshoot problems
*Monitor Stage*: Monitor and logging\

== The Devops lifecycle
#figure(
  image("../figures/devops-lifecycle.png", width: 100%),
  caption: [
    DevOps Stages
  ],
)

*Continuous integration*
- Commit early, commit often
- Push code to the repository in the smallest possible size
- Push code to the repository frequently
- CI testing (DAST - Dynamic Application Security Testing, Unit Tests, Code Coverage)

*Continuous delivery & deployment*
- Testing/Production Environments are provisioned and configured
- Continuous Delivery requires a trigger to deploy the application while in Continuous Deployment this is automated.
- Verify how the application works under load
- Strategies: Rolling deployment: Deploy in groups. Blue-Green deployment: Deploy a new version alongside the old one. Canary deployment: Deploy to a subset of users

*Continuous Feedback*
- Happens at the beginning and end of the continuous lifecycle
- Metrics, statistics, analytics, and feedback from the customer and
teams involved are considered to continuously improve the product

== DevOps in GitLab CI
GitLab CI is a Continuous Integration server built right into GitLab
- Build, test and deploy code automatically on every change
- Keep building scripting together with the code
- Works on gitlab.com or your GitLab server

*Building and testing with Docker*\
Building a docker image from within a docker container that the GitLab Ci is running for us.\
A docker registry is built into the repository (`$CI_REGISTRY`) `$CI_REGSITRY_IMAGE` is the path where the build image is going to be located.
Use docker login to login into the registry using the `$CI_JOB_TOKEN`

#sourcecode[```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

build:
  stage: build
  image: docker:stable
  services:
    - docker:dind
  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
  before_script:
    - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
    - docker info
  script:
    - docker build -t $DOCKER_IMAGE_TAG .
    - docker push $DOCKER_IMAGE_TAG

test:
  stage: test
  image: node:10
  services:
    - name: postgres:10
```]

== DevOps with GitLab CI: Build stages, artifacts, and dependencies
*Using build stages*\
Each stage contains one or more jobs.
Stages are run in the order they are declared.
Any job failure marks the stage as failed.
When you do not declare stages, the default stages are
- build
- test
- deploy

*Running build steps in parallel*\
By assigning two jobs to the same stages, Gitlab CI runs the two jobs in parallel together.
The parallel tag creates copies of the same job and runs them in parallel.

*Speeding up builds with the cache*\
We can specify paths to cache the modules and speed up future builds. (The `$CI_COMMIT_REF_SLUG` is a variable that identifies the branch.)
This Variable can be used to reference the cache folder from the branch.

#sourcecode[```yaml
cache:
  key: $CI_COMMIT_REF_SLUG
  paths:
    - node_modules/
```]

*Defining artifacts*\
We can define artifacts of files we would like to keep.
You can configure it to only keeping artifacts when a job has succeeded.
Artifacts can be used in future jobs of the pipeline and downloaded via the Gitlab web interface or API.
In the .gitlab-ci.yml, a new key “artifacts is defined.

#sourcecode[```yaml
artifacts:
  paths:
    - package-lock.json
    - npm-audit.json
```]

The key when can be added.
3 options
- On success
- On failure
- Always
The default is on success

*Using artifacts in future stages*\
By default, any artifacts produced in one job is going to be available to the other jobs.
- The test job will get both artifacts (because it has no explicit dependencies)
- The test2 job will get only the artifact from the build2 (because of the dependency)

#grid(
  columns: (auto, auto),

  sourcecode[```yaml
build:
  stage: build
  script:
    - echo "I am an artifact" > artifact.txt
  artifacts:
    paths:
      - artifact.*

build2:
  stage: build
  script:
    - echo "I am also an artifact" > artifact2.txt
  artifacts:
    paths:
      - artifact2.*
```],

sourcecode[```yaml
test:
  stage: test
  script:
    - cat artifact*.*

test2:
  stage: test
  dependencies:
    - build2
  script:
    - cat artifact2.*
```]
)

*Passing variables to builds*\
There are a few ways to define variables for a script:
- Per step in the pipeline definition
- Globally for all steps in the pipeline definition
- When executing a pipeline manually
- On repository level
- On group level

These variables are available as environment variables during the build.