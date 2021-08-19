# Control Plane - GitHub Actions Example Using Terraform

This example demonstrates how to build and deploy your application to Control Plane using Terraform as part of a CI/CD pipeline. 

It can be used as a template for your applications.

## Script Overview

The example demonstrates how to deploy multiple branches to Control Plane by using an input action. 

The action file `.github/actions/inputs/action.yml`, is used by the workflow file `.github/workflow/deploy-to-control-plane.yml` to configure the pipeline based on the branch.

The action will:
- Install the Control Plane CLI
- Install the Control Plane Terraform Provider
- Configure environment variables

The action sets the environment variables used by the variables (prefixed with `TF_VAR_`) in the Terraform script. Any additional variables should be added to the action and set in the workflow.

By default, the workflow will run the Terraform Plan command to display the changes that will be deployed.  To apply the changes, the workflow must be executed manually and the apply flag set to true. When executing manually, there is also an option to deploy a specific commit SHA.

The workflow will:
- Check out the code.
- Run the input action based on the branch
- Authenticate, build and push the application to the org's private image repository if the apply flag is set to true. The short SHA is used as the image tag.
- Set the Terraform cloud token
- Run the Terraform init and validate command
- Run the Terraform plan command if the apply flag is set to false
- Run the Terraform apply command if the apply flag is set to true

## Terraform Action Items

The example uses `Terraform Cloud` to store the state file. Follow these instructions to set up an account and workspace.

- Create an account at: https://app.terraform.io/

- Create a organization and add one or more workspaces. The name of the workspace should have the same prefix (e.g., cpln-dev, cpln-prod).

- Set the execution mode to `local` in the general settings.

- In the `/terraform/terraform.tf` file, update the `organization` name and `workspaces` block . The `prefix` value will be prepended
to the input's Terraform workspace variable. This can be used to deploy to multiple environments, each of them having their own state file.

## Resources to Create/Update

- Create a Control Plane Service Account and add a key
    - Add the Service Account to the `superusers` group. Once the workflow executes as expected, a policy can be created with a limited set of permissions and the Service Account can be removed from the superusers group.
    - Create and save a key. It will be used in the next step.

- Add the following variables as repository secrets (settings -> secrets):
    - `CPLN_TOKEN`: Service Account Key
    - `TERRAFORM_CLOUD_TOKEN`: Terraform Cloud Token

- Review and update the `.github/workflows/deploy-to-control-plane.yml` file:
  - Line 8 and 9: Uncomment and update with the action (e.g., push, pull request, etc.) and branch names (e.g., dev, main, etc.) this workflow will trigger on.
  - Lines 33 and 46: Update the branch names to match line 9.
  - Lines 36 and 49: Update ORG_NAME.
  - Lines 41 and 54: Update IMAGE_NAME_DEV_BRANCH and IMAGE_NAME_MAIN_BRANCH. The action will append the short SHA of the commit when pushing the image to the org's private image repository.
  - Lines 39/40 and 52/53: Update the GVC and workspace name.
  - Lines 43 and 56: Update the Terraform workspace name. Do not include the common prefix.

- The Terraform script is located in the `/terraform` directory. Review and update the file `terraform.tf` with the resources needed for your application and the following:
  - `TERRAFORM_ORG`: Terraform Cloud organization
  - `WORKSPACE_PREFIX`: Terraform Workspace Prefix. If deploying to multiple branches/environments, a workspace needs to be defined for each having the same prefix (e.g., cpln-dev, cpln-prod, etc.). The workspace (dev and prod), is defined using the input action (Lines 43 and 56 in the workflow file.)

- The file `/terraform/.terraformrc` must be included to allow Terraform to authenticate to their cloud service. No modification is necessary. The workflow will update the credentials during execution.

## Helper Links

- <a href="https://www.terraform.io/docs/index.html">Terraform Documentation</a>

- <a href="https://www.terraform.io/docs/cli/config/config-file.html" _target="_blank">Terraform Cloud Credentials</a>
  
- <a href="https://docs.github.com/en/actions" target="_blank">GitHub Actions Docs</a>

