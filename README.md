# eks-atlantis

> :warning: **This repository is for demo purposes only. It is not production ready!**

## Table of contents
- [Introduction](#introduction)
- [Assumptions and decisions](#assumptions-and-decisions)
- [Pre-commit](#pre-commit)
- [1. Requirements](#1-requirements)
- [2. Infrastructure deployment](#2-infrastructure-deployment)
- [3. Kubernetes deployment](#3-kubernetes-deployment)
- [4. Configuring Atlantis on GitHub](#4-configuring-atlantis-on-github)
- [F.A.Q](#faq)
- [Known issues](#known-issues)
- [Improvements](#improvements)

## Introduction

This repository contains the code to deploy a EKS cluster with Atlantis installed on it.
As required, the infrastructure is deployed using `terraform` and the applications are deployed using `helm_provider`.

In summary, the code in this repository will deploy the following resources:
**Infrastructure:**
- 1 VPC
- 4 Subnets (2 publics and 2 privates)
- 1 Internet Gateway
- 1 EKS cluster
- 1 KMS key `<project>-<env>-secrets`. I.e.: `atlantis-dev-secrets`
- IAM roles and policies (for EKS, atlantis, load balancer, ebs-csi-driver)

**Application - Atlantis:**
- Load balancer controller (helm chart)
- EBS CSI driver (helm chart)
- Atlantis (helm chart)
- 1 Load balancer (for atlantis)
- 1 EBS 5Gb (for atlantis)
- 1 Secret manager (for store secrets)

## Assumptions and decisions
- I'm assuming you have all the requirements installed and configured (check the requirements section) and an AWS account with admin permissions to run the code. I'll not cover AWS account creation nor setup of IAM Role/User and AWS credentials. Check the [documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id.html)
- The private subnets were created w/o NAT Gateways since it's required for now. For demo purposes, I'm creating the cluster in a public subnet, but it's not recommended for production environments.
- The KMS key were created by me to encrypt Atlantis Secret, but it's not required.
- I'm using `local` backend for terraform state to keep it simple. For production environments, I recommend to use `s3` backend.

## Pre-commit

This repository uses [pre-commit](https://pre-commit.com/) to run some checks before commit the code. The checks are:
- `terraform fmt` to format the terraform code
- `terraform-docs` to generate the documentation for the terraform code
- `tflint` to check for errors in the terraform code
- `check-yaml` to check for errors in the yaml files
- `end-of-file-fixer` to fix the end of file
- `trailing-whitespace` to remove trailing whitespace


## 1. Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.4.0`
- AWS Credentials (by default it uses the `default` profile. You can change it on `provider.tf` file or export the AWS_PROFILE variable). More [info](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- GitHub Personal Access Token ([PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)) with admin permissions: `repo`
- [tlint](https://github.com/terraform-linters/tflint) (optional)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (optional)
- [terraform-docs](https://terraform-docs.io/) (optional)

## 2. Infrastructure deployment

1. Clone this repository
2. Change to the `infrastructure` folder and run `terraform` commands:
```bash
terraform init # initialize terraform
terraform plan # check the changes
terraform apply # apply the changes
```

It should take around 12-15 minutes to deploy the infrastructure.

The result should be similar to this:
```bash
Apply complete! Resources: 56 added, 0 changed, 0 destroyed.

Outputs:
...
```

## 3. Kubernetes deployment

1. Before apply the terraform code, you should **prepare the secrets** required by atlantis.
Change to the `kubernetes` folder and use the following template:

```bash
tee -a atlantis_secrets.txt <<EOF
{
   "gh_token":"<GH_PAT_TOKEN>",
   "gh_user":"<GH_USERNAME>",
   "gh_webhook_secret":"<ATLANTIS_WEBHOOK_SECRET>",
   "org_allowlist":"github.com/<GH_USERNAME>/*".
   "atlantis_basic_auth_user":"<ATLANTIS_BASIC_AUTH_USER>",
}
EOF
```

The command above should create the file `atlantis_secret.txt` in your current folder.

2. **Encrypt the github secrets** using the KMS key created by terraform in the first step (check the KMS_KEY_ID in the output of the terraform apply command)

```bash
aws kms encrypt --key-id 19168d02-52f0-42f6-abf7-5c6c2d824916 --plaintext fileb://atlantis_secrets.txt --output text --query CiphertextBlob
```

The output should be similar to this:

```bash
AQICAHizssoq3XEox0DPWvjDiWHNFaia/ycogFm00Uh54GqNUwGCWIzEOu9XDTI2kyPi1TWWAAABCzCCAQcGCSqGSIb3DQEHBqCB+TCB9gIBADCB8AYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARAPHAEL7t9hom7l698XICARCAgcKjVpDOzZ4EQSp+Fy6t3/Hc89PxB7R0k197FOMOLjwVxxx4DtppcFH/q8viQo5Ca22i6QCfMCa+n6vs4G7KnyBUMpb6TByY/I3v0DwAaIHsqHK5gj3zuMyIicepnlVkaz4cAPoaugoKoZeqXizCZnHL+GoXj7MVO8WNgo1EfZjfjeOCpOvU8oYo4E6mH8ZT8sUdjxRABELLOxuntsd2cEz04pQ+wu5q/o6AGB9Qfw+K/jkIa0kb29+j3/RTsJumj2D6RPQ==
```

Add the output to the `terraform.tfvars` file for as the value for the variable `atlantis_encrypted_secrets`:

```bash
echo 'atlantis_encrypted_secrets="AQICAHizssoq3XEox0DPWvjDiWHNFaia/ycogFm00Uh54GqNUwGCWIzEOu9XDTI2..."' >> terraform.tfvars
```

Alternatively, you can use the [kms-encrypter](https://github.com/MrKoopaKiller/kms-encrypter) :)

3. Run terraform commands to **deploy atlantis**:

```bash
cd kubernetes
terraform init # initialize terraform
terraform plan # check the changes
terraform apply # apply the changes
```

After few minutes you should get the similar output:

```bash
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.
```

4. Get EKS cluster access

To access the EKS cluster with `kubectl` you need first to retrieve the credentials from AWS:

```bash
aws eks update-kubeconfig --region eu-central-1 --name atlantis-dev
```

The output should be similar to:

```bash
Updated context arn:aws:eks:eu-central-1:977133975186:cluster/atlantis-dev in ~/.kube/config
```

Try kubectl commands to check if you can access the cluster:

```bash
λ › kubectl get pods -n atlantis
NAME         READY   STATUS    RESTARTS   AGE
atlantis-0   1/1     Running   0          8m22s
```

5. Getting the Atlantis URL

To get the Atlantis URL you need to run the describe ingress command in the namespace `atlantis`:

```bash
λ › kubectl describe ingress -n atlantis
NAME       CLASS    HOSTS   ADDRESS                                                                    PORTS   AGE
atlantis   <none>   *       k8s-atlantis-atlantis-20b222b711-84937600.eu-central-1.elb.amazonaws.com   80      10m
```
Take notes of the ADRESS, you will need it to configure the webhook on github.

## 4. Configuring Atlantis on GitHub

1. Get the Atlantis Ingress URL by running the command below:

```bash
kubectl describe ingress -n atlantis
```

2. Follow the instructions on [atlantis documentation](https://www.runatlantis.io/docs/configuring-webhooks.html#github-github-enterprise) to configure the webhook on github. Replace the `$URL` with the ingress URL from the previous step.

**Note:** Ensure that the URL you paste is `http://` instead of `https://` since the load balancer is not using SSL certificate for this PoC.

> **TL;DR**
>
> 1. Create new GH webhook with the following settings:
>  - Payload URL: `http://k8s-atlantis-atlantis-20b222b711-482977740.eu-central-1.elb.amazonaws.com/events`
>- Content type: `application/json`
>- Secret: The same value of `gh_webhook_secret` you configured on `atlantis_secrets.txt` file
>- Events: `Let me select individual events` and select `Pull requests`, `Pull request reviews`,`Issue comments` and `Pushes`

## F.A.Q

##### **Q:** For what is the `EBS-CSI driver` and `Load Balancer controller`?
**A**: The `ebs-csi-driver` is required by atlantis to store temp data. The `load-balancer-controller` is required to create the load balancer for the webhook.

##### **Q:** Why `helm_release` :sad:?
**A:** Since it's the code is just for a PoC, I consider the `helm_release` the easiest way to deploy helm charts and to manage the application. IMHO, and based on my previous experience, **it's not the best way for productions environments** since the `helm_release` has some issues and sometimes it doesn't work as expected. Check the improvements section for details.

##### **Q:** WHy you are using `templatefile()` for `atlantis_values.yaml` file?
**A:** The `set` parameter for `helm_release` has some interpolation issues and might cause problems depending on the name/value of the parameter. That's why I prefer, in that case, to use a template file and fullfill with the values that I need.

##### **Q:** Why you are encrypting the atlantis secrets with KMS?
**A:** It's just because I wanted to store my secrets on github and I didn't want to use a third party tools to encrypt the secrets, like `sops` or `git-crypt`. Only the person with access to the KMS key can decrypt the secrets. It's a good practice to encrypt secrets, even if they are stored in a private repository.

## Known issues

##### 1. The load balancer is not destroyed when `terraform destroy` is executed

> `Error: uninstallation completed with 1 error(s): timed out waiting for the condition`

It is a known issue from the `helm_release` resource. It should be deleted automatically when the `helm_release` is deleted. But if you destroy the cluster first than the `helm_release` it will not be deleted. You need to delete it manually.

##### 2. The atlantis pod in `pending` state

There are many reason why the pod is in `pending` state. Here are some tips to check:

- Lack of resources: check if the node has enough resources to run the pod. I did have some problems in t3.small instance families. I recommend to use t3.medium or bigger.
- Check if the PersistentVolumeClaim is created and bounded to the PersistentVolume. If not, check the logs of the `ebs-csi-driver` pod. It might be a problem with the IAM role or the EBS CSI driver is not installed properly.
- Check the logs of the `atlantis` pod. It might be a problem with the IAM role or atlantis configuration.
- Check if the `ebs-csi-driver` is installed properly and using the correct IAM role with the annotation `ebs.csi.aws.com/role`. If not installed or running, fix it first.

## Improvements

- S3 backend for terraform state
- Remove Admin permissions from the atlantis IRSA
- SSL certificate for the load balancer + custom domain
- Use argocd or fluxcd to deploy helm charts
