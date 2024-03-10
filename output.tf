output "github_repository_ids" {
  value = {
    for idx, repo in local.repositories_data.organization_repositories :
    idx => github_repository.github-management[idx].id
  }
}

output "github_team_ids" {
  value = {
    for team_name, _ in local.teams_data.teams :
    team_name => github_team.team[team_name].id
  }
}

output "github_team_membership_info" {
  value = {
    for team_name, team_members in local.teams_data.teams :
    team_name => {
      for member in team_members.members :
      member.username => {
        team_id = github_team.team[team_name].id
        role    = member.role
      }
    }
  }
}
