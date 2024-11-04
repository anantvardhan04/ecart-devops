locals {
  services-names = ["search"]
  services-names-parameter = {
    search = {
      service_name     = "search"
      container_port   = "8005"
      memory_reserv    = "100"
      github_branch    = "master"
      github_repo      = "ecart-backend"
      github_owner     = "anantvardhan04"
      docker_image_url = "975050162729.dkr.ecr.ap-south-1.amazonaws.com/dev-amcart-search:latest"
    },
  }
  frontend-services-names = ["frontend"]
  frontend-services-names-parameter = {
    frontend = {
      service_name  = "frontend"
      github_branch = "master"
      github_repo   = "ecart-frontend"
      github_owner  = "anantvardhan04"
      s3_bucket     = "ecart-static-content"
    }
  }
}
