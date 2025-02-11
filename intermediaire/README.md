# TP Intermédiaire

## Objectif

Ce TP vise à vous familiariser avec des concepts essentiels de Terraform tels que les workspaces, meta-arguments, les fonctions et expressions ainsi que les modules.

Bonne chance !

## Prérequis

- Récupération de l'Access Key et Secret Key AWS (à voir avec le formateur)
- [Installation de Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Installation de la CLI AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
- [Configuration de l'authentification à AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-wizard)
- Se placer à l'intérieur du dossier `intermediaire`

## Exercices

### Configuration du provider

- Créer un fichier `providers.tf` permettant de configurer Terraform pour utiliser le provider AWS.

  ```tf
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
  }

  provider "aws" {
    region = "eu-west-1"
  }
  ```

### Configuration du Module `terraform-aws-tfstate-backend`

#### Contexte

Lorque plusieurs utilisateurs doivent apporter des modifications sur le même projet Terraform, ceux-ci doivent partager le même fichier "state". Ce fichier contenant potentiellement des informations sensibles, nous souhaitons éviter de l'héberger sur un repo Git (par exemple).

#### Objectif

L'objectif de cet exercice est de configurer à l'aide du module [terraform-aws-tfstate-backend](https://github.com/cloudposse/terraform-aws-tfstate-backend) un Bucket S3 qui hébergera le "state" terraform. Une table "DynamoDB" est également créée pour y stocker un "LockID" afin d'éviter les exécutions concurrentes entre plusieurs utilisateurs.

#### Instructions

- Créer un fichier `s3-backend.tf` avec le contenu suivant:

  ```tf
  module "terraform_state_backend" {
    source = "cloudposse/tfstate-backend/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version     = "1.4.1"
    namespace  = "formation"
    stage      = "terraform"
    name       = "${STUDENT_NAME}"
    attributes = ["state"]

    terraform_backend_config_file_path = "."
    terraform_backend_config_file_name = "backend.tf"
    force_destroy                      = false
  }
  ```

- Remplacer `${STUDENT_NAME}` par votre nom
- Lancer un `terraform init`
- Lancer un `terraform plan` et un `terraform apply`
- Commenter le contenu du fichier `s3-backend.tf`

_Aide:_

- [Provider AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Dependency Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)

### Création de workspaces

Les Workspaces permettent de gérer plusieurs "states" pour une même base de code Terraform. Couplé au système de branches sur Git, cela permet d'effectuer plusieurs instanciations en parallèle pour maintenir par exemple des environnements différents (dev, prod).

- Quel est le nom du workspace actuellement utilisé ?
- Créer un workspace `dev`

_Aide_:

- [Gestion des workspaces](https://developer.hashicorp.com/terraform/cli/workspaces)

#### Utilisation du workspace dans les ressources

L'objectif de cet exercice est d'obtenir une ressource ayant des propriétés diffétentes en fonction du workspace pour lequel le code Terraform est exécuté.

Dans un fichier `s3.tf`, créer un Bucket S3 ayant pour format de nom: `<my-bucket>-<terraform-workspace>-<uuid>`. Le Bucket devra également avoir un tag `env = "<terraform-workspace>"`.

_Aide:_

- [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [terraform.workspace](https://developer.hashicorp.com/terraform/language/state/workspaces#current-workspace-interpolation)

### Méta-arguments

#### Count avec une liste

L'objectif de cet exercice est de définir un nombre d'instanciation d'une ressource en fonction de la valeur d'une variable (ici la longueur d'une liste).

Créer une ressource `aws_vpc`:

- Plage réseau du VPC: `10.0.0.0/16`

Dans uns fichier `vars.tf`, créer la variable suivante:

```tf
variable "my_subnets" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
```

Créer une ressource `aws_subnet` capable de s'instancier autant de fois qu'il y a d'éléments dans la liste `my_subnets`.

Inverser l'ordre des éléments de la `list`. Que constatez-vous ?

_Aide:_

- [Resource: aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Count meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/count)
- [Length Function](https://developer.hashicorp.com/terraform/language/functions/length)

#### Count avec une map

Modifier le code de l'exercice précédent pour qu'il fonctionne avec une `map` plutôt qu'une `list`.
Ajouter également un tag sur la ressource avec pour clé: `name` et pour valeur: `app` ou `db` suivant le subnet.

```tf
variable "my_subnets" {
  type = map(string)
  default = {
    "app" = "10.0.1.0/24",
    "db" = "10.0.2.0/24"
  }
}
```

Inverser l'ordre des éléments de la `map`. Que constatez-vous ?

_Aide:_

- [Values function](https://developer.hashicorp.com/terraform/language/functions/values)
- [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

#### Foreach avec un set

L'objectif de cet exercice est de définir un nombre d'instanciation d'une ressource en fonction de la valeur d'une variable.

Modifier le code de l'exercice précédent pour qu'il fonctionne avec un `set` plutôt qu'une `list`.

```tf
variable "my_subnets" {
  type = set(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
```

Inverser l'ordre des éléments de la `map`. Que constatez-vous ?

_Aide:_

- [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

#### Foreach avec une map

Modifier le code de l'exercice précédent pour qu'il fonctionne avec une `map` plutôt qu'une `list`.
Ajouter également un tag sur la ressource avec pour clé: `name` et pour valeur: `app` ou `db` suivant le subnet.

```tf
variable "my_subnets" {
  type = map(string)
  default = {
    "db" = "10.0.1.0/24",
    "app" = "10.0.2.0/24"
  }
}
```

Inverser l'ordre des éléments de la `map`. Que constatez-vous ?

_Aide:_

- [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

#### Dépendances explicites

Dans le fichier `s3.tf`, modifier la spec du Bucket S3, pour l'obliger à être créé avant le VPC défini dans `network.tf`.

_Aide:_

- [depends_on](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)

### Fonctions Réseaux

L'objectif de cet exercice est d'utiliser une fonction liée au réseau.

Dans le fichier `network.tf`, créer une ressource `aws_network_interface` pour chaque réseau déclaré dans la variable `my_subnets`.

L'adresse IP de l'interface devra être la 6e IP du subnet (exemple: `10.0.1.5` si le réseau est `10.0.1.0/24`).

_Note_: Il sera beaucoup plus simple d'itérer directement sur la ressource `aws_subnet` plutôt que la variable `my_subnets`.

_Aide_:

- [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Ressource: aws_network_inerface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)
- [Fonction: cidrhost](https://developer.hashicorp.com/terraform/language/functions/cidrhost)

### Modules 1/3

L'objectif de cet exercice est de créer un module local permettant de standardiser la création d'une interface réseau pour chaque subnet créé.

Dans le dossier courant, créer l'arborescence suivante:

```tf
.
└── modules/
    └── aws_network_interface/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

Le fichier `main.tf` doit contenir la définition de la ressource `aws_network_interface` initialement défini dans le fichier `network.tf`.

Le fichier `variables.tf` doit définir les variables nécessaires à la création de la ressource `aws_network_interface`. Celles-ci sont injectées dans le module au moment de son appel par le module parent.

Dans le module parent, le fichier `network.tf` déjà existant devra appeler le module `aws_network_interface` et lui fournir les variables nécessaires à son exécution.

Enfin, créer une output permettant d'afficher en console les IDs des interfaces réseaux créées.

_Aide:_

- [Appel d'un module](https://developer.hashicorp.com/terraform/language/modules/syntax#calling-a-child-module)
- [Appel d'un module local](https://developer.hashicorp.com/terraform/language/modules/sources#local-paths)
- [Créer un module](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Composition d'un module](https://developer.hashicorp.com/terraform/language/modules/develop/composition)
- [Accéder à l'output d'un module enfant](https://developer.hashicorp.com/terraform/language/values/outputs#accessing-child-module-outputs)

### Modules 2/3

L'objectif de cet exercice est de mettre à jour le module pour autoriser certaines interfaces à reçevoir du trafique depuis le subnet dans lequel elles se trouvent:

- Si l'interface est créée dans le subnet `app`, celle-ci doit autoriser le port `443` en entrée.
- Si l'interface est créée dans le subnet `db`, celle-ci doit autoriser le port `3306` en entrée.

La correspondance entre le nom du subnet et le port à ouvrir sera défini dans le module enfant à l'aide de la variable suivante:

```tf
variable "ports" {
  type = map(string)
  default = {
    app = "443"
    db = "3306"
  }
}
```

Note: Il sera nécessaire de fournir au module enfant d'autres informations pour réaliser cet exercice.

_Aide:_

- [Resource: aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/3.22.0/docs/resources/security_group#example-usage)

### Modules 3/3

L'objectif de cet exercice est de mettre à jour le module pour autoriser ou non d'autres flux vers les interfaces créées. Ces flux seront définis dans le fichier `vars.tf` du module parent:

```tf
variable "admin_flows" {
  type = object({
    enabled = bool
    source = string
    source_prod = string
  })
  default = {
    enabled = true
    source = "53.28.94.7/32"
    source_prod = "85.35.47.10/32"
  }
}
```

_Aide:_

- [Expressions conditionnelles](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [Count Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/count)

## Nettoyage

- Dé-commenter le contenu du fichier `s3-backend.tf`
- Utiliser la commande `terraform destroy` pour détruire l'ensemble des ressources créées durant ce TP.
- Utilisez la commande `terraform workspace select default` puis relancez un `terraform destroy` pour supprimer le remote state.

_Aide:_

- [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)
