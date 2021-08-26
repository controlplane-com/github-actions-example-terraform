# Control Plane - GitHub Actions Example Using Terraform

This example demonstrates how to build and deploy an application to Control Plane using Terraform as part of a CI/CD pipeline. 

The sample application is a Node.js web application that will display the environment variables that exist in the running container and the arguments that were used when executing the container. A sample Dockerfile is included to assist in the building of the container.

Terraform requires the current state be persisted between deployments. This example uses [Terraform Cloud](https://app.terraform.io/) to manage the state.

This example is provided as a starting point and your own unique delivery and/or deployment requirements will dictate the steps needed in your situation.

## Terraform Cloud Set Up

Follow these instructions to set up an account and workspace at Terraform Cloud:

1. Create an account at [https://app.terraform.io/](https://app.terraform.io/).

2. Create an organization. Keep a note of the organization. It will be used in the example set up section.

3. Create a workspace. Select the `CLI-driven workflow` type. The example uses a `workspace prefix` when configuring the workspace block in the `/terraform/terraform.tf` file. This allows a Terraform workspace to be used for each branch deployed. The prefix is prepended to the value of the environment variable `TF_WORKSPACE` when Terraform is executing. When creating the workspace in the wizard, the name should be the prefix followed by the branch name. For example, `cpln-dev` and `cpln-main` (prefix is `cpln-`). Keep a note of the workspace. It will be used in the example set up section.

4. Set the execution mode to `local` in the general settings.

5. Create an API token:
    - Click on your user profile and select `User settings`.
    - Click Tokens.
    - Click `Create an API token`, enter a description, and click `Create API token`.
    - Keep a note of the token. It will be used in the GitHub set up section.

## Control Plane Authentication Set Up 

The Terraform provider and Control Plane CLI require a `Service Account` with the proper permissions to perform actions against the Control Plane API. 

1. Follow the Control Plane documentation to create a Service Account and create a key. Take a note of the key. It will be used in the next section.
2. Add the Service Account to the `superusers` group. Once the workflow executes as expected, a policy can be created with a limited set of permissions and the Service Account can be removed from the `superusers` group.
   

## GitHub Set Up

The example require the following variables be added as a secret:

- `CPLN_TOKEN`: Service Account Key
- `TF_CLOUD_TOKEN`: Terraform Cloud Token

Browse to the Secrets page by clicking `Settings` (top menu bar), then `Secrets` (left menu bar).

## Example Overview and Set Up

When triggered, the GitHub action will execute the steps defined in the workload file located at `.github/workflow/deploy-to-control-plane.yml`. The workflow will generate a Terraform plan based on the HCL in the `/terraform/terrafrom.tf` file. The HCL will create/update a GVC and workload hosted at Control Plane. After the plan has been reviewed, the action needs to be manually triggered with the apply flag set to true. This apply flag will execute the steps that will containerize and push the application to the org's private image repository and apply the Terraform plan. 

The action file `.github/actions/inputs/action.yml`, is used by the workflow file to configure the pipeline based on the branch and input variables. This can be used to deploy multiple branches as individual GVCs/workloads to Control Plane.

**The action will:**
- Install the Control Plane CLI.
- Install the Control Plane Terraform Provider.
- Configure the required environment variables based on the input from the workflow.

The action sets the environment variables used by the variables in the Terraform script (prefixed with `TF_VAR_`). Any additional variables needed should be added to the action and set in the workflow.

**The workflow will:**
- Check out the code.
- Run the action based on the branch.
- Authenticate, containerize and push the application to the org's private image repository if the apply flag is set to true. 
- Set the Terraform cloud token.
- Run the Terraform init and validate command.
- Run the Terraform plan command if the apply flag is set to false.
- Run the Terraform apply command if the apply flag is set to true.

**Perform the following steps to set up the example:**

1. Fork the example into your own workspace.

2. Review and update the `.github/workflows/deploy-to-control-plane.yml` file:
    - Line 9: Uncomment and update with the action (e.g., push, pull request, etc.) and branch names (e.g., dev, main, etc.) this workflow will trigger on.
    - Lines 33 and 46: Update the branch names to match line 9.
    - Lines 36 and 49: Update ORG_NAME.
    - Lines 41 and 54: Update IMAGE_NAME_DEV_BRANCH and IMAGE_NAME_MAIN_BRANCH. The action is set to append the short SHA of the commit when pushing the image to the org's private image repository.
    - Lines 39/40 and 52/53: Update the GVC and workspace name.
    - Lines 43 and 56: Update the Terraform workspace name. Do not include the common prefix.

3. Update the Terraform HCL file located at `/terraform/terraform.tf` using the values that were created in the `Terraform Cloud Set Up` section:
    - `TERRAFORM_ORG`: The Terraform Cloud organization.
    - `WORKSPACE_PREFIX`: The Terraform Workspace Prefix. Only enter the prefix. Terraform will automatically append the value of the `TF_WORKLOAD` environment variable that was set in the action when pushing the state to the Terraform cloud. This comes in handy when deploying to multiple branches as each branch will have its own workspace (hosting the state) within the Terraform Cloud. 

4. The file `/terraform/.terraformrc` must be included to allow Terraform to authenticate to their cloud service. No modification is necessary. The workflow will update the credentials during execution using the `sed` command on line 71.

**To manually trigger the GitHub action:**

1. From within the repository, click `Actions` (top menu).
2. Click the `Deploy-To-Control-Plane` link under `Workflows`.
3. Click the `Run workflow` pulldown button. 
4. Select the branch to use.
5. Update the `Apply Terraform` text box to `true` to apply the Terraform updates.
6. Optionally, add the SHA of a specific commit to deploy. Leave empty to deploy the latest. 
7. Click `Run workflow`.

## Running Example Application

After the action has successfully deployed the application, it can be tested by following these steps:

1. Browse to the Control Plane Console.
2. Select the GVC that was set in the action's gvc variable.
3. Select the workload that was set in the action's workload variable.
4. Click the `Open` button. The example application will open in a new tab. It will display the environment variables that exist in the running container and the arguments that were used when executing the container.


## Helper Links

Terraform

- <a href="https://www.terraform.io/docs/index.html">Terraform Documentation</a>

- <a href="https://www.terraform.io/docs/cli/config/config-file.html" _target="_blank">Terraform Cloud Credentials</a>
  
GitHub

- <a href="https://docs.github.com/en/actions" target="_blank">GitHub Actions Docs</a>

