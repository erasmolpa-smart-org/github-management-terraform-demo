# GitHub Management Terraform Demo

This project is a Terraform project for creating resources in GitHub.

## Local Environment Setup

These are the instructions for setting up the local environment and running the project on your machine.

### Prerequisites

Make sure you have the following prerequisites installed on your system:

- [Terraform](https://www.terraform.io/) (version X.X.X or higher)
- [Git](https://git-scm.com/)
- [pre-commit](https://pre-commit.com/)


### Configuration Steps

1. **Clone the Repository:**

   Clone this repository to your local machine using Git:

   ```bash
   git clone https://github.com/erasmolpa-smart-org/github-management-terraform-demo.git
   ```

2. **Set GitHub Provider Configuration:**

   Before applying the Terraform configuration, you need to set the GitHub provider configuration. Open the `main.tf` file and configure the GitHub provider block:

   ```hcl
   # Configure the GitHub Provider
   provider "github" {
     owner = var.github_owner
     token = var.github_token
   }
   ```

   Replace `var.github_owner` and `var.github_token` with your GitHub owner and access token respectively. It's recommended to use environment variables or other secure methods to manage sensitive information like access tokens.



### YAML Files in the `config` Folder

In the `config` folder of this project, you will find several YAML files containing input configuration for creating resources on GitHub. These YAML files are used as input for the Terraform process and define organization members, teams, repositories, and associated permissions.

- **members.yaml**: Defines organization members using their GitHub usernames and assigns them specific roles.

  ```yaml
  members:
    - username: "erasmolpa"
      role: "member"
    - username: "erasmodominguezdc"
      role: "member"
  ```

- **repositories.yaml**: Defines the repositories to be created in the GitHub organization, specifying their name, description, and visibility.

    ```yaml
    organization_repositories:
    - name: "voxsmart-service-api"
        description: "Main business Service API"
        visibility: private
    - name: "voxsmart-service-ui"
        description: "Front Service UI"
        visibility: private
    - name: "voxsmart-service-sdk"
        description: "Backend core SDK Framework"
        visibility: public
    ```

- **teams.yaml**: Defines teams in GitHub and associates a list of members with each team.

    ```yaml
    teams:
    frontend_team:
        name: "frontend_team"
        description: "Team for frontend developers"
        privacy: "closed"
        members:
        - username: "erasmolpa"
            role: "member"
    backend_team:
        name: "backend_team"
        description: "Team for backend developers"
        privacy: "closed"
        members:
        - username: "erasmodominguezdc"
            role: "member"
        - username: "erasmolpa"
            role: "member"
    ```
- **repository_permissions.yaml**: Defines access permissions to the repositories for different teams.

    ```yaml
    repositories:
    - name: "voxsmart-service-api"
        teams:
        - name: "backend_team"
            permission: "admin"
        - name: "frontend_team"
            permission: "pull"
    - name: "voxsmart-service-ui"
        teams:
        - name: "frontend_team"
            permission: "admin"
    - name: "voxsmart-service-sdk"
        teams:
        - name: "frontend_team"
            permission: "push"
        - name: "backend_team"
            permission: "push"
    ```

This configuration is load as terraform locals as bellow:

    ```hcl
    locals {
    repositories_data                = yamldecode(file("${path.module}/config/repositories.yaml"))
    members_data                     = yamldecode(file("${path.module}/config/members.yaml"))
    teams_data                       = yamldecode(file("${path.module}/config/teams.yaml"))
    teams_repository_permission_data = yamldecode(file("${path.module}/config/repository_permissions.yaml"))

    team_repository_permissions = flatten([
        for repository in local.teams_repository_permission_data.repositories :
        [
        for team in repository.teams :
        {
            repository_name = repository.name
            team_name       = team.name
            permission      = team.permission
        }
        ]
    ])
    }
    ```
**NOTE**: Please , remember this is just a first MVP or POC. For a production readyness implementation , we will need to modify this approach


## Technical Notes: Assumptions and Future Improvements


### Assumptions:
1. **Manual Repository Management**: The current infrastructure involves manually managing all code repositories within the GitHub organization. This manual approach has led to inconsistencies in configurations across repositories.

2. **Infrastructure as Code (IaC) Adoption**: The decision to adopt an Infrastructure as Code approach aims to ensure consistency in repository configurations and streamline the management of users within the GitHub organization.

3. **Initial Implementation**: The initial implementation focuses on creating repositories, managing team memberships, and assigning permissions within the GitHub organization.

4. **GitHub Organization Membership**: The GitHub organization does not have a centralized identity service configured. As a result, users will be added directly to the GitHub organization.

5. **Team Structure**: Developers are divided into two teams: Frontend and Backend. Each team has specific access levels to repositories based on their role.

### Future Improvements:

Future improvements are based on the assumption that what is intended is to manage and provide centralized governance of a GitHub organization(s) in a large company. The implementation and strategy to follow can vary greatly depending on the distribution and size of said organization. Therefore, future improvements are a rough proposal of what could be taken into account.


1. **Centralized State Management**:
    - *Description*: Implementing a centralized backend for storing Terraform state files will enhance collaboration and ensure consistency in infrastructure deployments.
    - *Technical Approach*: Use remote state management with separate state files for each resource type (e.g., repositories, teams, members).
  
    ```hcl
    terraform {
    backend "s3" {
        bucket         = "smart-org-storage"
        key            = "repositories.tfstate"
        region         = "us-west-1"
        dynamodb_table = "repo-state-locked-table"
    }
    }
    ```

**NOTE: Depending on the company size and the number of resources to be manage under IaC , we will need to split the states into multiples of them . For example , if we are expecting to create Thousands of repositories, will be not possible to maintain a single repository state. We can split by teams , (thousands of states files) or by any business unit . Another important aspect to be consider is the way we provide this IaC to the teams. Wrappers such as Terragrunt , can help a lot to simplify the way we manage environments and to increase the usability  **


1. **Modular Terraform Configuration**:
    - *Description*: Breaking down the Terraform configuration into separate modules for each resource type (e.g., repositories, teams) will improve code organization and maintainability.
    - *Technical Approach*: Create individual Terraform modules for managing repositories, teams, and memberships with reusable configurations.
  
```hcl

module "repositories" {
  source = "source = "git::https://github.com/erasmolpa-smart-org/github-repositories-terraform-module.git?ref=v1.0.0""
  ...
  .....
  .......
}

module "teams" {
  source = "source = "git::https://github.com/erasmolpa-smart-org/github-teams-terraform-module.git?ref=v1.0.0""
  ....
  .....
  .......
}

module "members" {
  source = "source = "git::https://github.com/erasmolpa-smart-org/github-members-terraform-module.git?ref=v1.0.0""
  ....
  .....
  .......
}
```

1. **Scalability and Governance**:
    - *Description*: Enhancing the solution to support scalability and governance requirements, such as implementing policies for repository naming conventions and defining code owners for repositories.
    - *Technical Approach*: Define naming conventions using Terraform variables and implement code owners configuration using GitHub's CODEOWNERS file.

2. **Self-Service Provisioning**:
    - *Description*: Implementing self-service capabilities for developers to request repository creation and manage access permissions through an automated process.
    - *Technical Approach*: Develop a custom web application or use GitHub Actions to automate repository creation and permission management based on user requests.

3. **Import Existing Resources**:
    - *Description*: Adding functionality to import existing repositories, teams, and user memberships from the GitHub organization before fully implementing Terraform. This will ensure a seamless transition and preserve existing configurations.
    - *Technical Approach*: Use Terraform's `import` feature to import existing resources into Terraform state files, allowing for further management using Terraform.

4. **Naming Convention Enforcement**:
    - *Description*: Enforcing naming conventions for repositories to maintain consistency and improve clarity across the organization's codebase.
    - *Technical Approach*: Define naming conventions in Terraform variables and use input validation to enforce these conventions during resource creation.

5. **Code Owners Configuration**:
    - *Description*: Implementing code owners configuration for repositories to designate individuals or teams responsible for code review and approvals.
    - *Technical Approach*: Utilize GitHub's CODEOWNERS file and Terraform's GitHub provider to programmatically configure code owners for repositories.

6. **Enhanced Collaboration**:
    - *Description*: Promoting a collaborative and service-oriented approach to infrastructure management, fostering cross-team collaboration and knowledge sharing.
    - *Technical Approach*: Implement features such as automated notifications, documentation generation, and centralized communication channels to facilitate collaboration among teams.
