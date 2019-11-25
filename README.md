# terraform-aws-bootstraper

A terraform module to configure a [terraform remote state](https://www.terraform.io/docs/state/remote.html) for your AWS accounts.

## Usage

Terraform uses [state](https://www.terraform.io/docs/state/index.html) in order to keep track of your infrastructure and configuration. When working with Terraform in a team setting, it is recommend to use [terraform remote state](https://www.terraform.io/docs/state/remote.html). The `terraform-aws-bootstrapper` module creates the necessary resources to store the `terraform.tfstate` file remotely using an S3 [backend](https://www.terraform.io/docs/backends/index.html) and DynamoDB. Therefore the `terraform.tfstate` file for the remote state configuration must be kept with the code repository in which it is deployed.

Before deploying infrastructure with terraform we recommend creating a directory structure similar to this example:

```bash
terraform/
├── README.md
├── application
│   └── main.tf
└── bootstrap
    ├── .gitignore
    └── main.tf
```

We strongly recommend using a `.gitignore` in the bootstrap directory that includes:

```
.terraform/
terraform.tfstate.backup
```

### Variables

#### Required

* `source` - Tells Terraform where to find the source code for the desired module. See [Terraform documentation](https://www.terraform.io/docs/modules/sources.html) for more info.
* `bucket_name` - The name of the bucket that will hold your terraform state file.
* `bucket_source_account_id` - The AWS account ID where you want to create your terraform remote state.
* `account_ids` - The AWS accounts that will use the remote state.
* `lock_table_names` - The name(s) of the DynamoDB table(s) that will be created.

### Example

```terraform
module "my-aws-terraform-remote-state" {
  source                   = "USSBA/bootstrapper/aws"
  bucket_name              = "my-terraform-remote-state-bucket"
  bucket_source_account_id = "000011112222"
  account_ids              = ["000011112222", "333344445555"]
  lock_table_names         = ["my-terraform-remote-state-locktable"]
}
```

Add the module to `bootstrap/main.tf` using the example above and deploy it to your infrastructure. You may now [configure](https://www.terraform.io/docs/backends/config.html) your project to use the [S3 backend](https://www.terraform.io/docs/backends/types/s3.html) using a similar example:

```terraform
terraform {
  backend "s3" {
    bucket         = "my-terraform-remote-state-bucket"
    key            = "path/to/my/key"
    region         = "us-east-1"
    dynamodb_table = "my-terraform-remote-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
```

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the license and in no way imply compensation for contributions.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.

The agency reserves the right to change this policy at any time.