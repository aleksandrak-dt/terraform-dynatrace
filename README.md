# terraform-dynatrace
Create monitoring zones and synthetic tests in Dynatrace via Terraform
1. First step is to make sure you have installed Terraform and an EDE. Folow this steps to get going with Terraform: https://docs.dynatrace.com/docs/manage/configuration-as-code/terraform
2. Create a token for your repo with listed scopes as in instructions: https://docs.dynatrace.com/docs/manage/configuration-as-code/terraform/teraform-basic-example
4. Copy the repo and add a .cmd file in the repo. This file will contain the environment url and the token, additionally if you like more context to the created resources, input your own app id, name, env and namespace. If you don't want to use there environments, please remove them from the rest of the code.<br />
```SET DYNATRACE_ENV_URL=https://<your-dynatrace-tenant>.apps.dynatrace.com/
SET DYNATRACE_API_TOKEN=dt0c01.xx.xxxx
SET TF_VAR_app_id=<app-id>
SET TF_VAR_app_name=<app-name>
SET TF_VAR_app_env=<app-env>
SET TF_VAR_app_namespace=<app-namespace>
```
<br />
5. In a CMD Terminal (I do it in VS Code on Windows) and execute following commands:

```
Command: <my-environments>.cmd
Terraform init
Terraform apply -auto-approve
Terrraform destroy -auto-approve
```

Make sure you always destroy the terraform created resources via terraform destroy. 
