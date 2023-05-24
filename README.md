# ndo.gi

URL shortener for mid-sized SaaS company.

Tech-Stack:

- Application: Node.JS
- Infrastructure
  - Terraform
  - AWS
    - ECS, Fargate
    - RDS
    - VPC, Load Balancers
- DevOps: GitHub Actions

## Overview

- [Getting started](#getting-started)
  - [Requirements](#requirements)
  - [Deploying and destroying](#deploying-and-destroying)
- [API](#api)
  - [POST /link](#post-link)
  - [DELETE /link](#delete-link)
- [Configuration](#configuration)
- [Optimizations](#optimizations)
  - [Engineering perspective](#engineering-perspective)
    - [Usability](#usability)
    - [Stability](#stability)
    - [Quality Assurance](#quality-assurance)
    - [Security](#security)
    - [Observability](#observability)
    - [Scalability](#scalability)
  - [Business perspective](#business-perspective)
    - [Costs](#costs)
    - [Income](#income)
- [Contribution](#contribution)

## Getting started

### Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Node.JS and NPM](https://nodejs.org/en/download)

### Deploying and destroying

To install all dependencies, run:

```#bash
npm run setup
```

Afterwards, create a [.env](.env) file and [configure it](#configuration).

To deploy a new environment, run:

```#bash
npm run apply
```

To destroy your environment, run:

```#bash
npm run destroy
```

## API

### POST /link

Creates a new shortened link.

Parameters:

- `short: String` The short form of the link, e.g. `"gh"`
- `target: String` The target URL, e.g. `"https://github.com"`

### DELETE /link

Deletes a link.

Parameters:

- `short: String` The short form of the link to delete, e.g. `"gh"`

## Configuration

| Name | Type | Description |
| --- | --- | --- |
| **AWS_ACCESS_KEY_ID** | String | Required; the Access Key for the AWS account. |
| **AWS_SECRET_ACCESS_KEY** | String | Required; the secret access key for the AWS account. |
| **TF_VAR_environment** | String | Required; the name of the environment that will be deployed. Must be unique to prevent impacting other environments or developers. For local development, choose `local-myname`. |
| DATABASE_HOST | String | _Local only;_ Host of the MySQL database, e.g. `"localhost"` |
| DATABASE_NAME | String | _Local only;_ Name of the MySQL database, e.g. `"ndogi"` |
| DATABASE_PASSWORD | String | _Local only;_ Password to access the MySQL database, e.g. `"12345678"` |
| DATABASE_PORT | Integer | _Local only;_ Port of the MySQL database, e.g. `3306` |
| DATABASE_USERNAME | String | _Local only;_ Username to access the MySQL database, e.g. `"root"` |
| TF_VAR_aws_account_id | Integer | The ID of the AWS account to deploy to. |
| TF_VAR_database_host | String | Host of the MySQL database, e.g. `"localhost"` |
| TF_VAR_database_name | String | Name of the MySQL database, e.g. `"ndogi"` |
| TF_VAR_database_password | String | Password to access the MySQL database, e.g. `"12345678"` |
| TF_VAR_database_port | Integer | Port of the MySQL database, e.g. `3306` |
| TF_VAR_database_username | String | Username to access the MySQL database, e.g. `"root"` |
| TF_VAR_enable_debugging | Boolean | Whether to enable debugging in the deployed resources or not. |

## Optimizations

### Engineering perspective

#### Usability

- Application
  - UI. Obviously.
  - API Client: Create an API client library in common programming languages for easy integration by customers
- Infrastructure
  - Domain: Use a common domain that remains across multiple (un-)deployments within the same environment with [Route 53](https://aws.amazon.com/route53/) and [API Gateway](https://aws.amazon.com/api-gateway/).

#### Stability

- Application
  - Possible race condition for database setup when launching multiple ECS with a database update in parallel
  - Version API
- Infrastructure
  - Deploy updates in separate environment with monitoring, redirect increasing amount of traffic to the new version (start low, end with 100 %)
  - Reuse VPC across feature-environments
  - Separate production-, staging- and feature- environment by using different AWS accounts
  - Deploy to multiple [Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones)
  - RDS Replica in different Availability Zones

#### Quality Assurance

- Application
  - Unit tests
  - Integration tests
  - End-to-End tests
    - Better coverage
    - Instead of sleeping for 120s, check if API is online in the desired version before starting
  - Test coverage reports, analysis and requirements
- Dependencies (e.g. NPM, Docker, scripts, Terraform providers, )
  - Fix dependency versions
  - Check for deprecations (currently only NPM)
  - Check for vulnerabilities (currently only NPM)
  - Test for unused dependencies
- Infrastructure
  - Terraform: Write plan to a file to assure that exact plan will be applied
  - Docker
    - Image versioning
  - Load tests
- CI/CD
  - Rewrite scripts in Python/Node.JS/TypeScript to make them less environment-dependent for local development and support better Quality Assurance within the CI/CD scripts
  - Validate script parameters
  - Test in different environments to assure Windows/Mac users can deploy, develop and test locally

#### Security

- Application
  - Use separate database connection for [multiple-statement queries during setup](https://github.com/mysqljs/mysql#multiple-statement-queries).
  - Authenticate users before deleting links.
- Infrastructure
  - Create robot-users with least-privilege, encapsulated in each environment
  - VPC: Assure database can only be accessed by ECS in same environment
  - RDS: Encrypt database and use KMS authentication

#### Observability

- Application
  - Use a proper logging module instead of `console`
- Infrastructure
  - Connect to CloudWatch, Datadog, ELK, or Grafana
  - Create Dashboard with important cost-metrics
  - Create cost-alerts
  - RDS
    - Enable logging and monitoring

#### Scalability

At the moment, the application has limited scalability.

- RDS: Scales up to 1 TB of storage
- ECS: Needs [Autoscaling configuration](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html) and a test-case to verify the scaling works as intended

### Business perspective

#### Costs

- Application
  - Optimize memory cache to reduce CPU and RDS load - e.g. depending on the amount of commonly requested links - or remove it to reduce memory size
    - Evaluate potential savings by utilizing Fargate Ephemeral Storage for disk-cache
  - Handle unused or dead URLs
    - Move URLs to second "cold storage" database (slower, only requested if link cannot be found in primary database) or into disk storage
    - Remove URLs which's targets become unavailable
    - Remove URLs if not requested within a specific period
    - Only keep shorts in database, move URLs to disk ("cold storage")
- ECS
  - Use [Compute Savings Plans](https://aws.amazon.com/savingsplans/compute-pricing/) to reduce costs outside of peak hours
    - Consider paying upfront (depending on capital costs)
  - Investigate if using [Lambdas](https://aws.amazon.com/lambda/) in a hybrid setup for peak hours can reduce costs
  - Utilize [S3](https://aws.amazon.com/s3/) to serve static content instead of express
- RDS
  - Use [Reserved Instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html)
- Development and Maintenance
  - Outsource some tasks to countries with lower wages

#### Income

- Reserved namespaces
  - Charge for usage of reserved namespaces (e.g. "/Eat...", "/Buy..." for advertisers)
  - Allow companies/individuals to rent namespaces (e.g. "/LH..." to allow Lufthansa to create quick-info screens to flights like "/LH591")

## Contribution

This repository loosely follows the [Git Flow branch-model](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) with a master, develop, and any amount of feature-branches.

To submit your code, create a feature branch and, once the Quality Assurance tests pass, a Pull Request to `develop`.

### Development

The repository includes a [list of recommended VSCode-extensions](https://github.com/megatheriums/ndogi/blob/develop/.vscode/extensions.json) to make your life easier.

All CI/CD scripts can be run locally using `npm run [script-name]`:

| Script | Purpose | Description |
| --- | --- | --- |
| `apply` | Deployment | Deploys the infrastructure. |
| `destroy` | Deployment | Destroys the infrastructure. |
| `fix` | Debugging | Runs all fixes |
| `fix:node:audit` | Debugging | Updates dependencies to fix the audit. |
| `fix:node:lint` | Debugging | Fixes linting errors in the application code. |
| `fix:terraform:lint` | Debugging | Fixes linting errors in the infrastructure code. |
| `plan` | Deployment | Creates a deployment plan for the infrastructure. |
| `publish` | Deployment | Builds and uploads a new docker image. |
| `setup` | Setup | Installs all dependencies. |
| `setup:production` | Setup | Installs the production dependencies (excludes development- and testing- tools). |
| `start` | Running | Starts the server locally. |
| `test` | Testing | Runs all tests |
| `test:node:audit` | Testing | Audits the Node.JS dependencies for security vulnerabilities; see [npm audit](https://docs.npmjs.com/auditing-package-dependencies-for-security-vulnerabilities) |
| `test:node:e2e` | Testing | Runs End-to-End tests. Requires an environment to be started and [configured](#configuration). |
| `test:node:lint` | Testing | Checks the linting of Node.JS code |
| `test:terraform:lint` | Testing | Checks the linting of the Infrastructure code |
