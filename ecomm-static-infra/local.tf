locals {
  services-names = ["ecartsearch"]
  services-names-parameter = {
    ecartsearch = {
      service_name     = "ecartsearch"
      container_port   = "8005"
      memory_reserv    = "100"
      github_branch    = "master"
      github_repo      = "ecart-backend"
      github_owner     = "anantvardhan04"
      docker_image_url = "149536485745.dkr.ecr.ap-south-1.amazonaws.com/dev-ecart-ecartsearch:latest"
    },
  }
  frontend-services-names = ["ecartfrontend"]
  frontend-services-names-parameter = {
    ecartfrontend = {
      service_name  = "ecartfrontend"
      github_branch = "master"
      github_repo   = "ecart-frontend"
      github_owner  = "anantvardhan04"
      s3_bucket     = "ecart-static-content"
    }
  }
}
