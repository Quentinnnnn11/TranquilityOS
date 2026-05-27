# Tranquility OS
Tranquility OS est un système d'exploitation sécurisé et durci basé sur **NixOS**, conçu spécifiquement pour le déploiement en environnement d'entreprise.

L'objectif de ce projet est de fournir une alternative robuste à Windows pour les parcs informatiques, en combinant la reproductibilité des **Nix Flakes** avec une gestion centralisée via Git, tout en s'intégrant parfaitement aux infrastructures Active Directory existantes.

## Fonctionnalités Principales
- **Architecture Flake-based :** Configuration globale 100 % reproductible et versionnée.

- **Déploiement Agnostique :** Le code centralisé ne contient aucune configuration matérielle spécifique, permettant un déploiement sur n'importe quel type de poste (Fixe, Portable, VM).

- **Installateur Interactif Personnalisé :** Une image ISO maison embarquant un script de déploiement.

- **Intégration Active Directory à la demande :** Un module maison (tranquility.ad) permet de joindre un domaine via SSSD et adcli directement lors de l'installation.

## Structure du Dépôt
```bash
TranquilityOS/
├── assets
│   └── wallpaper.png
├── common
│   ├── active-directory.nix    # Module maison pour la gestion SSSD/Kerberos
│   ├── desktop.nix             # Paramètres de l'environnement de bureau KDE Plasma
│   ├── packages.nix            # Définition des packets installés
│   ├── plasmaKiosk.nix         # Paramètres de verrouillage de KDE Plasma
│   └── print.nix               # Définition des drivers d'impression
├── iso/
│   └── installer.sh            # Script d'installation interactif en Bash
├── configuration.nix           # Paramètres communs du système d'exploitation
├── flake.nix                   # Point d'entrée de la configuration globale
└── iso.nix                     # Configuration de génération de l'ISO bootable
```

Note : Des fichiers "local-config.nix" et "hardware-configuration.nix" sont générés à la volée sur les machines clientes et ne sont pas suivis par Git.

## Processus d'Installation (Client)
1. Démarrez la machine sur une clé USB avec l'ISO Tranquility OS monté au préalable.

2. Une fois sur l'écran d'accueil, lancez l'installateur avec les droits d'administration :
    ```Bash
    sudo tranquility-install
    ```

3. Suivez l'assistant interactif qui vous demandera des informations de base telles que :
    - Le nom de la machine et la création du compte administrateur local.
    - La configuration réseau.   
    - La volonté de rejoindre (ou non) un domaine Active Directory.
    - Le disque cible à formater et le choix d'activer l'hibernation.

> Note : Ce script d'installation est personnalisable à 100% afin de répondre aux besoins des différents clients. Ainsi, ce script peut être automatisé à 100%.

4. Le script se charge de la configuration, du clonage du dépôt et de l'installation.
Une fois terminé, redémarrez, et la machine est **opérationnelle**.

## Mise à jour du Parc
Une fois les machines déployées, les mises à jour du système d'exploitation (ajout d'un logiciel, modification des règles de sécurité) se font simplement en modifiant le dépôt Git.

Par défaut, les machines clientes se mettent automatiquement à jour tous les lundi matin à la première connexion.

> Note : Il est possible de forcer la mise à jour sur une machine en lancant les commandes suivantes (connecté en administrateur local) :
> ```Bash
> sudo cd /etc/nixos
> sudo git pull origin main
> sudo nixos-rebuild switch --flake .#TranquilityOS
> ```
> Cela aura pour effet de récupérer la nouvelle configuration sur Github et de recompiler le système.
> Pas besoin de redémarrer, à la fin de l'execution de la commande, le système sera à jour.
