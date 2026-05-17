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

## Générer l'ISO d'Installation
Pour compiler l'image d'installation de Tranquility OS depuis un environnement NixOS :

1. Clonez ce dépôt :
    ```bash
    git clone https://github.com/Quentinnnnn11/TranquilityOS.git
    cd TranquilityOS
    ```
2. Lancez la compilation de l'ISO :
    ```Bash
    nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
    ```
3. L'image générée se trouvera dans le dossier result/iso/. Vous pouvez la flasher sur une clé USB (via Ventoy, BalenaEtcher, dd, ...).

## Processus d'Installation (Client)
1. Démarrez la machine cible sur la clé USB Tranquility OS.

2. Une fois sur l'écran d'accueil, lancez l'installateur avec les droits d'administration :
    ```Bash
    sudo tranquility-install
    ```

3. Suivez l'assistant interactif qui vous demandera :
    - Le nom de la machine et la création du compte local de secours.   
    - La volonté de rejoindre (ou non) un domaine Active Directory.
    - Le disque cible à formater et le choix d'activer l'hibernation.

4. Le script se charge du partitionnement, du clonage du dépôt et de l'installation.
Une fois terminé, redémarrez, et la machine est **prête** et **enrôlée**.

## Mise à jour du Parc
Une fois les machines déployées, les mises à jour du système d'exploitation (ajout d'un logiciel, modification des règles de sécurité) se font simplement en modifiant ce dépôt Git.

Sur une machine cliente, il suffit de tirer les modifications et de recompiler :

```Bash
sudo cd /etc/nixos
sudo git pull origin main
sudo nixos-rebuild switch --flake .#TranquilityOS
```

## Reste à faire
- garbage collector
- maj auto
