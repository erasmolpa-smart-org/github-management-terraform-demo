resource "github_membership" "members" {
  for_each = {
    for member in local.members_data.members :
    member.username => member
  }

  username = each.value.username
  role     = each.value.role
}

resource "github_team" "team" {
  for_each = {
    for team_name, team_config in local.teams_data.teams :
    team_name => team_config
  }

  name                      = each.value.name
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = true
}

resource "github_team_membership" "members" {
  for_each = {
    for team_name, team_config in local.teams_data.teams :
    team_name => team_config.members
  }

  team_id = github_team.team[each.key].id

  username = each.value[0].username # Accede al primer elemento de la lista de miembros
  role     = each.value[0].role     # Accede al primer elemento de la lista de miembros
}

resource "github_repository" "github-management" {
  for_each = {
    for idx, repo in local.repositories_data.organization_repositories :
    idx => repo
  }

  name               = each.value.name
  description        = each.value.description
  visibility         = try(each.value.private, "private")
  archive_on_destroy = try(each.value.archive_on_destroy, true)
  has_issues         = try(each.value.has_issues, true)
  has_wiki           = try(each.value.has_wiki, true)
  has_projects       = try(each.value.has_wiki, true)
  allow_merge_commit = try(each.value.allow_merge_commit, false)
  allow_squash_merge = try(each.value.allow_squash_merge, true)
  allow_rebase_merge = try(each.value.allow_rebase_merge, true)
  auto_init          = try(each.value.auto_init, false)
  license_template   = try(each.value.license_template, "mit")
  gitignore_template = try(each.value.gitignore_template, "")
  is_template        = try(each.value.is_template, false)

  vulnerability_alerts = true

  #!FIXME. Enabling the security scan it makes the apply fail.
  security_and_analysis {
    secret_scanning {
      status = "disabled"
    }
    secret_scanning_push_protection {
      status = "disabled"
    }
  }
}

resource "github_branch_protection" "github-management-branch-protection" {
  count = length(local.repositories_data.organization_repositories)

  repository_id          = github_repository.github-management[count.index].node_id
  pattern                = "main"
  enforce_admins         = true
  allows_deletions       = false
  require_signed_commits = true
}

resource "github_repository_tag_protection" "github-management-tag-protection" {
  count = length(local.repositories_data.organization_repositories)

  repository = github_repository.github-management[count.index].name
  pattern    = "v*"
}

resource "github_team_repository" "team_repo" {
  for_each = {
    for repo in local.repositories_data.organization_repositories :
    "${repo.team}-${repo.name}" => repo
  }

  team_id    = github_team.team[each.value.team].id
  repository = each.value.name
  permission = "push"

}
