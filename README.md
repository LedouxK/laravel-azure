# Laravel sur Azure avec Terraform

Ce projet est une application Laravel configurée pour être déployée sur Azure App Service via Terraform et GitHub Actions.

## Prérequis

- Un compte Azure avec un abonnement actif
- Terraform installé localement
- Git installé localement
- Docker installé localement

## Configuration

1. Créez les secrets GitHub suivants dans votre repository :

```
AZURE_CREDENTIALS - Les credentials Azure Service Principal
REGISTRY_LOGIN_SERVER - L'URL de votre Azure Container Registry
REGISTRY_USERNAME - Le nom d'utilisateur de votre ACR
REGISTRY_PASSWORD - Le mot de passe de votre ACR
```

2. Configurez les variables d'environnement dans le fichier `.env` :

```bash
cp .env.example .env
php artisan key:generate
```

## Déploiement

Le déploiement est automatisé via GitHub Actions. À chaque push sur la branche main :

1. L'image Docker est construite et poussée vers Azure Container Registry
2. Terraform crée/met à jour l'infrastructure sur Azure
3. L'application est déployée sur Azure App Service

## Infrastructure

L'infrastructure créée comprend :
- Un groupe de ressources
- Un Azure Container Registry
- Un App Service Plan
- Une App Service

## Développement local

1. Installez les dépendances :
```bash
composer install
```

2. Lancez l'application avec Docker :
```bash
docker-compose up -d
```

3. L'application sera disponible sur `http://localhost:8000`

## Variables Terraform

Les variables suivantes sont nécessaires pour le déploiement :
- `docker_image`
- `docker_registry_url`
- `docker_registry_username`
- `docker_registry_password`
