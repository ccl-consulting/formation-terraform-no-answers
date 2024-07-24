# TP Acancé

## Objectif

Ce TP vise à vous familiariser avec la manipulation du state et à apporter des modifications au cycle de vie des ressources afin de couvrir des scénarios souvent rencontrés lors du MCO de projets utilisant Terraform.

Bonne chance !

## Prérequis

- Récupération de l'Access Key et Secret Key AWS (à voir avec le formateur) 
- [Installation de Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Installation de la CLI AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
- [Configuration de l'authentification à AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-wizard)
- Se placer à l'intérieur du dossier `avance`

## Exercices

### Data Source et For_Each :

L'objectif de cet exercice est de créer 3 enregistrements DNS en référençant une zone DNS déjà existante dans AWS.

- Utiliser la Data Source `aws_route53_zone` pour référencer dans Terraform la zone DNS qui sera utilisée dans la suite de cet exercice. Son nom: `student-<N>.com`.
- Créer autant de ressources `aws_route53_record` que d'éléments dans la `map` ci-dessous à l'aide d'un `for_each`:
    - `records`:
        - Adresse IP correspondant à l'application.
          Basé sur la variable suivante (créer un fichier `vars.tf`):
          ```
          variable "records" {
            type = map(string)
            default = {
              app1 = "10.0.0.1"
              app2 = "10.0.0.2"
              app3 = "10.0.0.3"
            }
          }
          ```
    - `name`:
        - Doit avoir le format `app<X>.student-<N>.com`
    - `zone_id`: La zone utilisée en Data Source
    - `type`: `"A"`
    - `ttl`: `300`

_Aide:_
- [Data Source: aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)
- [Resource: aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)
- [Meta-Argument: for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)


### Suppression et Import d'une ressource dans le State

L'objectif de cet exercice est de supprimer une ressource du state Terraform observer le comportement de l'`apply` suivant et de résoudre le problème via un import de cette même ressource.

- Supprimer du State Terraform l'enregistrement DNS correspondant à `app2` à l'aide de la commande `terraform state rm`.
- Observer le contenu du state Terraform (`cat terraform.tfstate`)
- Relancer un `terraform apply`
  - Que se passe-t-il et pourquoi ?
- Importer dans le state Terraform l'enregistrement DNS ayant été supprimé précédemment à l'aide de la commande `terraform import`.

_Aide:_
- [Terraform state: rm](https://developer.hashicorp.com/terraform/cli/commands/state/rm#example-remove-a-particular-instance-of-a-resource-using-for_each)
- [Terraform state: import](https://developer.hashicorp.com/terraform/cli/import)
- [Resource import: aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#import)


### Import d'une ressource avec écriture de la ressource

L'objectif de cet exercice est de gérer une ressource (une zone DNS) déjà existante avec Terraform plutôt que de simplement importer ses attributs via une data source. Nous expérimenterons une méthode qui permet de faciliter l'écriture de la spec de la ressource sans l'impacter par des changements involontaires.

- Créer une ressource `aws_route53_zone` générique:
  ```
  resource "aws_route53_zone" "my_zone" {
    name = "unknown"
    vpc {
      vpc_id = "unknown"
    }
  }
  ```
- Importer la ressource à l'aide de la commande `terraform import` sachant que l'ID de la zone DNS est le même que dans les exercices précédents. Il est aussi possible de créer une output de la data source `aws_route53_zone`.
- Lancer un `terraform plan` et observer les changements prévus
- Modifier la ressource `aws_route53_zone.my_zone` pour que le plan n'effectue pas de modification. Il n'est pas obligatoire de réécrire l'ensemble des attributs de la ressource. En renseignant uniquement les attributs `Required`, Terraform sera capable d'inclure la totalité des informations dans le state.
- Supprimer la data source `aws_route53_zone.my_zone` et modifier en conséquence la ressource `aws_route53_record.my_app` pour que celle-ci utilise les attributs de la ressource nouvellement importée.


_Aide:_
- [Import: route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#import)
- [Ressource: route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)


### Suppression d'une ressource sans passer par Terraform

L'objectif de cet exercice est d'observer le comportement de Terraform lorsqu'une ressource présente dans le state est supprimée sans passer par Terraform.

- Lancer le script [delete_route53_record.sh](delete_route53_record.sh) permettant de supprimer l'enregistrement DNS `app2.student-<N>.com`. 

  ```bash
  $ chmod +x delete_route53_record.sh
  $ ./delete_route53_record.sh
  HOSTED_ZONE_ID: ...
  SUDENT_NUMBER: ...
  ...
  ```
- Relancer un `terraform apply`. Que se passe-t-il ?


### Ajout d'un tag sur la Hosted Zone

- Ajouter un tag ayant pour valeur `Name = "student-<N>.com"` à la ressource `aws_route53_zone`

- Dans un fichier `vars.tf`, créer la variable suivante:

  ```
  variable "tags" {
    description = "A map of tags to add to resources"
    type        = map(string)
    default = {
      "Environment" = "Development"
      "Owner"       = "student-<N>"
    }
  }
  ```

- Utiliser la fonction `merge` pour fusionner les tags génériques de la variable `tags` au tag de la ressource `aws_route53_zone`.

_Aide:_
- [Ressource: route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)
- [Fonction: merge](https://developer.hashicorp.com/terraform/language/functions/merge)


### Tests

L'objectif de cet exercice est d'écrire un test unitaire pour le code Terraform.

Dans un nouveau fichier nommé `vars.tftest.hcl`, écrire un test permettant de vérifier que la variable `tags` ne contient pas une valeur ayant un caractère spécial pour la clé `Environment`.

_Aide:_
- [Tests](https://developer.hashicorp.com/terraform/language/tests)
- [Fonction: regexall](https://developer.hashicorp.com/terraform/language/functions/regexall)
- [Fonction: length](https://developer.hashicorp.com/terraform/language/functions/length)
- Il est possible d'utiliser `terraform console` pour tester les expressions


### Ignorer les changements

- Ajouter un tag `Test = true` à la variable `tags` du fichier `vars.tf`

- Utiliser la lifecycle policy `ignore_changes` pour ignorer l'ajout ou l'enlèvement de tags sur la ressource `aws_route53_zone`.

- Lancer un `terraform apply` et vérifier que le tag n'est pas ajouté

_Aide:_
- [Lifecycle Policy: ignore_changes](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes)


### Empêcher la destruction d'une ressource

- Utiliser la lifecycle policy `prevent_destroy` pour empêcher la destruction de la ressource `aws_route53_zone`

- Lancer un `terraform destroy` et vérifier que la ressource n'est pas détruite. Observer le comportement

_Aide:_
- [Lifecycle Policy: prevent_destroy](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#prevent_destroy)


## Nettoyage

Utiliser la commande `terraform destroy` pour détruire l'ensemble des ressources créées durant ce TP.

_Aide:_
- [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)