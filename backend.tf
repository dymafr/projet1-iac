terraform {
  cloud {
    organization = "Dyma" // Mettez ici le nom de votre organisation HCP

    workspaces {
      name = "projet1-iac" // Nom du workspace que nous allons créer
    }
  }
}
