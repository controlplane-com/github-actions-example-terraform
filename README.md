# Control Plane - GitHub Actions Example Using Terraform

This example demonstrates building and deploying an app to Control Plane using Terraform as part of a GitHub Action.

The example is a Node.js app that displays the environment variables and start-up arguments.

Terraform requires the current state be persisted between deployments. This example uses [Terraform Cloud](https://app.terraform.io/) to manage the state.

This example is provided as a starting point and your own unique delivery and/or deployment requirements will dictate the steps needed in your situation.

## Terraform Cloud Set Up

Follow these instructions to set up an account and workspace at Terraform Cloud:

1. Create an account at [https://app.terraform.io/](https://app.terraform.io/).

2. Create an organization. Keep a note of the organization. It will be used in the example set up section.

3. Create a workspace. Select the `CLI-driven workflow` type. The example uses a `workspace prefix` when configuring the workspace block in the `/terraform/terraform.tf` file. This allows a Terraform workspace to be used for each branch deployed. The prefix is prepended to the value of the environment variable `TF_WORKSPACE` when Terraform is executing. When creating the workspace in the wizard, the name should be the prefix followed by the branch name. For example, `cpln-dev` and `cpln-main` (prefix is `cpln-`). Keep a note of the workspace. It will be used in the example set up section.

4. Set the execution mode to `local` in the general settings. 
   - Click the `Settings` button in the top menu, then click the `General` button.
   - Click the `Local` radio button, then click the `Save Settings` button at the bottom of the page.

5. Create an API token.
   - Click on your user profile (upper right corner) and click `Account settings`.
   - Click Tokens on the left side menu.
   - Click `Create an API token`, enter a description, and click `Create API token`.
   - Keep a note of the token. It will be used in the example set up section.

## Control Plane Authentication Set Up 

The Terraform provider and Control Plane CLI require a `Service Account` with the proper permissions to perform actions against the Control Plane API. 

1. Follow the Control Plane documentation to create a Service Account and create a key. Take a note of the key. It will be used in the next section.
2. Add the Service Account to the `superusers` group. Once the GitHub Actions executes as expected, a policy can be created with a limited set of permissions and the Service Account can be removed from the `superusers` group.
  
## Example Set Up

When triggered, the GitHub action will execute the steps defined in the workload file located at `.github/workflow/deploy-to-control-plane.yml`. The workflow will generate a Terraform plan based on the HCL in the `/terraform/terraform.tf` file. The HCL will create/update a GVC and workload hosted at Control Plane. After the plan has been reviewed by the user, the action needs to be manually triggered with the apply flag set to `true`. This apply flag will execute the steps that will containerize and push the application to the org's private image repository and apply the Terraform plan. 

The action file `.github/actions/inputs/action.yml`, is used by the workflow file to configure the pipeline based on the branch and input variables (which are configured as repository secrets). This can be used to deploy multiple branches as individual GVCs/workloads to Control Plane.

**The action will:**
- Install the Control Plane CLI.
- Install the Control Plane Terraform Provider.
- Configure the required environment variables based on the input from the workflow.

The action sets the environment variables used by the variables (prefixed with `TF_VAR_`) in the Terraform HCL script (in the `/terraform/terraform.tf` file). Any additional variables  should be added to the action and set in the workflow.

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

2. The following variables are required and must be added as GitHub repository secrets.

```
Browse to the Secrets page by clicking `Settings` (top menu bar), then `Secrets` (left menu bar).
```

Add the following variables:

- `CPLN_ORG`: Control Plane org.
- `CPLN_TOKEN`: Service Account Key.
- `CPLN_GVC_DEV`: The name of the GVC for the `dev` branch.
- `CPLN_WORKLOAD_DEV`: The name of the workload for the `dev` branch.
- `CPLN_IMAGE_NAME_DEV`: The name of the image that will be deployed for the `dev` branch. The workflow will append the short SHA of the commit as the image tag when pushing the image to the org's private image repository.
- `TF_WORKSPACE_DEV`: The Terraform workspace name for the `dev` branch. **Do not include the common prefix used when setting up the workspace in the `Terraform Cloud Set Up` section.**
- `CPLN_GVC_MAIN`: The name of the GVC for the `main` branch.
- `CPLN_WORKLOAD_MAIN`: The name of the workload for the `main` branch.
- `CPLN_IMAGE_NAME_MAIN`: The name of the image that will be deployed for the `main` branch. The workflow will append the short SHA of the commit as the image tag when pushing the image to the org's private image repository.  
- `TF_WORKSPACE_MAIN`: The Terraform workspace name for the `main` branch. **Do not include the common prefix used when setting up the workspace in the `Terraform Cloud Set Up` section.**
- `TF_PROVIDER_VERSION`: The version number of the Control Plane Terraform Provider (Current version is: 1.0.1).
- `TF_CLOUD_TOKEN`: Terraform Cloud Authentication Token (from the `Terraform Cloud Set Up` section).

3. Review the `.github/workflows/deploy-to-control-plane.yml` file:
    - The workflow can be updated to be triggered on specific branches and actions (pushes, pull requests, etc.). The example is set to trigger on a push to the `main` and `dev` branch on lines 8-9 (currently commented out).
    - Lines 33 and 46: If necessary, update the branch names to match line 9.

4. Update the Terraform HCL file located at `/terraform/terraform.tf` using the values that were created in the `Terraform Cloud Set Up` section:
    - `TERRAFORM_ORG`: The Terraform Cloud organization.
    - `WORKSPACE_PREFIX`: The Terraform Workspace Prefix. Only enter the prefix. Terraform will automatically append the value of the `TF_WORKLOAD` environment variable that was set in the action when pushing the state to the Terraform cloud. This comes in handy when deploying to multiple branches as each branch will have its own workspace (hosting the state) within the Terraform Cloud. 

5. The file `/terraform/.terraformrc` must be included to allow Terraform to authenticate to their cloud service. No modification is necessary. The pipeline will update the credentials during execution with the value of the `TF_CLOUD_TOKEN` environment variable.

**To manually trigger the GitHub action:**

1. From within the repository, click `Actions` (top menu).
2. Click the `Deploy-To-Control-Plane` link under `Workflows`.
3. Click the `Run workflow` pulldown button. 
4. Select the branch to use.
5. Update the `Apply Terraform` text box to `true` to apply the Terraform updates.
6. Optionally, add the SHA of a specific commit to deploy. Leave empty to deploy the latest. 
7. Click `Run workflow`.

## Running the App

After the Github Action has successfully deployed the application, it can be tested by following these steps:

1. Browse to the Control Plane Console.
2. Select the GVC name that corresponds to the branch that was deployed.
3. Select the workload name that corresponds to the branch that was deployed.
4. Click the `Open` button. The app will open in a new tab. The container's environment variables and start up arguments will be displayed.

## Upgrading Provider Version

1. Update the `TF_PROVIDER_VERSION` repository secret with the desired provider version.
2. Update the version property inside the HCL file that contains the `required_providers` declaration block for the `cpln` provider. 
3. The example workflow runs the command `terraform init -upgrade` which will upgrade the Terraform dependencies (state file, etc.).

Note: If necessary, the provider version can be downgraded.


## Helper Links

Terraform

- <a href="https://www.terraform.io/docs/index.html">Terraform Documentation</a>

- <a href="https://www.terraform.io/docs/cli/config/config-file.html" _target="_blank">Terraform Cloud Credentials</a>
  
GitHub

- <a href="https://docs.github.com/en/actions" target="_blank">GitHub Actions Docs</a>

