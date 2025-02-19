# TP Débutant

## Objectif

Ce TP vise à vous familiariser avec les bases de Terraform en déployant et en gérant une ressource simple sur AWS. Vous allez créer un bucket S3, utiliser des variables et des datasources, générer un fichier template, et manipuler des outputs.

Bonne chance !

## Prérequis

- Récupération de l'Access Key et Secret Key AWS (à voir avec le formateur)
- [Installation de Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Installation de la CLI AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
- [Configuration de l'authentification à AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-wizard)
- Se placer à l'intérieur du dossier `debutant`

## Exercices

### Configuration du provider
  
- Créer un fichier `providers.tf` permettant de configurer Terraform pour utiliser le provider AWS. La région à utiliser sera `eu-west-1`
- Lancer la commande `terraform init`
- Inspecter le contenu du dossier `.terraform/providers/` que contient-il ?
- Inspecter le contenu du fichier `.terraform.lock.hcl` a quoi sert-il ?

_Aide:_

- [Provider AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Dependency Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)

### Création d'un "Bucket S3"

- Créer un fichier `resources.tf` dans lequel sera défini la ressource `aws_s3_bucket`
- Définissez son nom en utilisant l'argument `bucket`
- Expliquer ce qu'est un argument et donner un exemple pour la ressource `aws_s3_bucket`
- Expliquer ce qu'est un attribut et donner un exemple pour la ressource `aws_s3_bucket`
- Lancer la commande `terraform validate`. A quoi sert-elle ?
- Lancer la commande `terraform fmt`. A quoi sert-elle ?
- Appliquer les changements
- Observer à nouveau le contenu du fichier `terraform.tfstate`
- Utiliser la commande `terraform destroy` pour détruire le Bucket S3

_Aide:_

- [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- ⚠️ Le nom d'un bucket est unique dans une région et pour l'ensemble des utilisateurs
- [Argument](https://developer.hashicorp.com/terraform/docs/glossary#argument)
- [Attribut](https://developer.hashicorp.com/terraform/docs/glossary#attribute)
- [Arguments: aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#argument-reference)
- [Attributs: aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#attribute-reference)
- [terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)
- [terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)

### Découverte des commandes "plan" et "apply"

- Avant de créer une première ressource, exécuter la commande `terraform plan`. Que fait cette commande ?
- Exécuter ensuite la commande `terraform apply`. Quelle est la différence entre ces deux commandes ?
- Observez la création d'un nouveau fichier `terraform.tfstate` et inspectez son contenu

_Aide:_

- [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan)
- [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply)
- [terraform state](https://developer.hashicorp.com/terraform/language/state)

### Variabilisation du nom du Bucket S3 (.tfvars)

Variabiliser le nom donné au Bucket S3. Celui-ci sera défini dans un nouveau fichier nommé `vars.tf`

- Le nom de la variable sera `bucket_prefix`
- Ne pas définir de valeur par défaut pour le moment
- Lancer un plan/apply
- Au "prompt" de la variable `bucket_prefix` entrer le nom souhaité

Afin d'éviter un "prompt" de la valeur au lancement, définir une valeur par défaut (différente de l'ancienne) pour la variable `bucket_prefix`.

- Que se passe-t-il au lancement du plan/apply ?
- Valider le changement

Pour les questions suivantes, choisir un nom de bucket différent de la valeur par défaut pour s'assurer du succès de la commande:

- Effectuer un nouvel `apply` en exportant la variable d'environnement `TF_VAR_bucket_prefix`
- Effectuer un nouvel `apply` en surchargeant la valeur définie par défaut directement en CLI
- Effectuer un autre `apply` en surchargeant la valeur définie par défaut en utilisant un fichier de définition de variables nommmé `vars.tfvars`

Quel est l'ordre de priorité pour la prise en compte des variables ?

_Aide:_

- [Déclaration d'une variable](https://developer.hashicorp.com/terraform/language/values/variables#declaring-an-input-variable)
- [Utilisation d'une variable](https://developer.hashicorp.com/terraform/language/values/variables#using-input-variable-values)
- [Déclaration d'une variables en ligne de commande](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line)
- [Déclaration d'une variable dans un fichier dédié](https://developer.hashicorp.com/terraform/language/values/variables#values-for-undeclared-variables)
- [Utilisation d'une variable dans un fichier dédié](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- [Priorité sur la définition des variables](https://developer.hashicorp.com/terraform/language/values/variables#variable-definition-precedence)
- [Définition de variable d'environnement en powershell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.5#use-the-variable-syntax)

### Variabilisation du nom du Bucket S3 (locals / Data source)

L'objectif de cet exercice est de définir le nom du bucket à l'aide de deux variables:

- `bucket_prefix` (défini dans le fichier `vars.tf`)
- L'ID du compte AWS sur lequel la ressource est créée (obtenu à l'aide d'une `Data-Source` nommée `aws_caller_identity`)

Dans un nouveau fichier nommé `data.tf`:

- Définir la "data source" `aws_caller_identity` qui permettra d'obtenir l'attribut `account_id`

Dans un nouveau fichier nommé `locals.tf`:

- Creer une variable `bucket_name` concaténant la variable `bucket_prefix` et l'attribut `account_id` de la data source `aws_caller_identity`

Appliquer les changements

_Aide:_

- [Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)
- [Data source: aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity#account_id)
- [Déclaration d'une variable locale](https://developer.hashicorp.com/terraform/language/values/locals)
- [String Templates](https://developer.hashicorp.com/terraform/language/expressions/strings#string-templates)

### Upload d'un fichier dans le Bucket S3 (Argument Access / New Provider)

L'objectif de cet exercice est d'upload un fichier local dans le Bucket S3 créé précédemment en utilisant la ressource `aws_s3_object`. Les contraintes sont les suivantes:

- L'argument `bucket` doit spécifier le nom du bucket créé précédemment en appelant le bon attribut de la ressource `aws_s3_bucket`.
- L'argument `key` doit être une concaténation du nom du compte courant AWS (utilisé précédemment) et d'un UUID généré à l'aide de la ressource `random_uuid`.
- Le chemin du fichier spécifié dans l'argument `source` doit être défini depuis le fichier `.tfvars`.
- Utiliser le fichier `README.md` ou créer votre propre fichier à upload.

Pourquoi la commande `terraform init` est-elle nécessaire à nouveau ?

_Aide:_

- [Ressource: aws_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object)
- [Référence à une ressource](https://developer.hashicorp.com/terraform/language/expressions/references#resources)
- [Générer un UUID random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid)

### Interaction avec une ressource non gérée par Terraform (Data source)

L'objectif de cet exercice est de récupérer une ressource déjà existante (non gérée par Terraform) et de la copier dans le bucket S3 venant d'être créé.

Dans le fichier `data.tf`:

- Définir une "data source" référençant un fichier nommé `tf_logo.png` dans un bucket nommé `formation-terraform-common`.

Dans le fichier `resources.tf`:

- Utiliser la "data source" pour copier le fichier `tf_logo.png` dans le bucket créé précédemment.
- Le fichier de destination s'appellera `my_logo.png`
- Variabiliser ce qui peut l'être dans les arguments de `aws_s3_object_copy`

_Aide:_

- [Data Source: aws_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_object)
- [Resource: aws_s3_object_copy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object_copy)
- [Attribut: aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#attribute-reference)

### Affichage de métadonnées en sortie (Attribute Access / Outputs)

L'objectif de cet exercice est de récupérer une métadonnée d'une ressource et de l'afficher lors de l'exécution de Terraform.

Dans un nouveau fichier nommé `outputs.tf`:

- Créer un "output" permettant d'afficher la date de dernière modification du fichier `my_logo.png` créé dans l'exercice précédent.

Appliquer les changements et vérifier que cette date est bien affiché en sortie.

_Aide:_

- [Terraform Outputs](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Attribut: aws_s3_object_copy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object_copy#last_modified)

### Configuration d'un backend spécifique

L'objectif de cet exercice est de comprendre ce qu'est un Backend et comment le configurer.

Dans un nouveau fichier `backend.tf`:

- Définir un nouveau backend de type `local` permettant de choisir un nouvel emplacement pour le "state" Terraform. Celui-ci devra être stocké dans un fichier nommé `my_state.tfstate`
- Appliquer les changements et vérifier que le "state" se trouve bien dans le nouveau fichier
- Expliquer la différence entre le flag `-reconfigure` et le flag `-migrate-state`

_Aide:_

- [Configuration d'un Backend local](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#available-backends)
- [Migration du tfstate](https://developer.hashicorp.com/terraform/cli/commands/init#backend-initialization)

## Nettoyage

Utiliser la commande `terraform destroy` pour détruire l'ensemble des ressources créées durant ce TP.

_Aide:_

- [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)
