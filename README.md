# ndo.gi

URL shortener for mid-sized SaaS company.

- AWS, Terraform, Node.JS
- GitHub Actions QA
- RDS, ECS, Fargate
- Cost-efficient
- Scalable (High traffic and Traffic peaks)
- Maintainable
- Stable
- Release model

**Limitations:**

- Links cannot be updated once stored due to cache

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

Afterwards, create a [infrastructure/.env](infrastructure/.env) file as explained in [configuration](#configuration).

To deploy a new environment, run:

```#bash
npm run apply
```

To destroy your environment, run:

```#bash
npm run destroy
```

## Configuration

| Name | Type | Description |
| --- | --- | --- |
| AWS_ACCESS_KEY_ID | String | The Access Key for the AWS account. |
| AWS_SECRET_ACCESS_KEY | String | The secret access key for the AWS account. |
| TF_VAR_aws_account_id | Integer | The ID of the AWS account to deploy to. |
| TF_VAR_environment | String | The name of the environment that will be deployed. Must be unique to prevent impacting other environments or developers. For local development, choose `local-myname`. |
| TF_VAR_enable_debugging | Boolean | Whether to enable debugging in the deployed resources or not. |


## Optimizations

### Engineering perspective

#### Stability

- Deploy updates in separate environment with monitoring, redirect increasing amount of traffic to the new version (start low, end with 100 %)
- Separate production-, staging- and feature- environment by using different AWS accounts
- Deploy to multiple [Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones)
- RDS Replica in different Availability Zones
- Application:
  - Possible race condition for database setup when launching multiple ECS with a database update in parallel

#### Quality Assurance

- Dependencies (e.g. NPM, Docker, scripts, Terraform providers, )
  - Fix dependency versions
  - Check for deprecations
  - Check for vulnerabilities
  - Test for unused dependencies
- Infrastructure
  - Terraform: Write plan to a file to assure that exact plan will be applied
  - Assure AWS resource identifiers don't exceed length limits
    - This is a potential issue since resource names are often generated; with a long environment name - which can happen by auto-generating feature-environment names from branch names - these can get longer than supported by AWS.
    - Another way of mitigating the risk of duplicate resource names of future-environments is to remove other parts of the resource identifiers; for example, if the AWS account is used only by related projects, the "namespace"-prefix could be removed
  - Docker
    - Image versioning
- CI/CD
  - Rewrite scripts in Python/Node.JS/TypeScript to make them less environment-dependent for local development and support better Quality Assurance within the CI/CD scripts
  - Validate script parameters

#### Security

- Create robot-users with least-privilege, encapsulated in each environment
- VPC: Assure database can only be accessed by ECS in same environment
- RDS: Encrypt database and use KMS authentication
- Terraform: Don't print sensitive output values
- Application
  - Use separate database connection for [multiple-statement queries during setup](https://github.com/mysqljs/mysql#multiple-statement-queries).
  - Authenticate users before deleting links.

#### Automation

- Automatically create backend bucket and credentials separate project
- Store database version and execute all scripts in `data/sql` to update any database changes

#### Observability

- Application
  - Use a proper logging module instead of `console`
- Infrastructure
  - Tags: Utilize tags to make it easier to track usage in different environments or application parts
  - RDS
    - Enable logging and monitoring

### Business perspective

#### Optimizing costs

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
- RDS
  - Use [Reserved Instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html)
- Development and Maintenance
  - Outsource some tasks to countries with lower wages

#### Optimizing income

- Reserved namespaces
  - Charge for usage of reserved namespaces (e.g. "/Eat...", "/Buy..." for advertisers)
  - Allow companies/individuals to rent namespaces (e.g. "/LH..." to allow Lufthansa to create quick-info screens to flights like "/LH591")
