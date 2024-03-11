<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 5.45.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.github-management-branch-protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_membership.members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_repository.github-management](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_tag_protection.github-management-tag-protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_tag_protection) | resource |
| [github_team.team](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [github_team_repository.team_repo](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | n/a | `string` | `"erasmoXXXXXX"` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | n/a | `string` | `"gho_XXXXXXX"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
