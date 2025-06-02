terraform {
  backend "s3" {
    # REMPLACEZ par le nom exact de votre bucket S3 créé pour l'état
    bucket = "mon-tfstate-bucket-projet1-unique-12345"

    key    = "projet1-iac/main/terraform.tfstate" # Chemin du fichier d'état dans le bucket pour ce projet
    region = "eu-west-3"                          # Région de votre backend

    use_lockfile = true # Utilisation du verrouillage de l'état pour éviter les conflits
    encrypt      = true # Assure que l'état est chiffré au repos
  }
}
