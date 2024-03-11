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
