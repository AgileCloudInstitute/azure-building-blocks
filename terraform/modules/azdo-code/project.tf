#Copyright 2021 Green River IT (GreenRiverIT.com) as described in LICENSE.txt distributed with this project on GitHub.
#Start at https://github.com/AgileCloudInstitute?tab=repositories

resource "azuredevops_git_repository" "repository" {
  project_id = data.azuredevops_project.p.id
  name = var.repoName
  initialization {
    init_type = "Uninitialized"
  }
}

resource "azuredevops_build_definition" "build" {
  project_id = data.azuredevops_project.p.id
  name = var.buildName
  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type = "TfsGit"
    repo_id   = azuredevops_git_repository.repository.id
    yml_path  = "azure-pipelines.yml"
  }
}