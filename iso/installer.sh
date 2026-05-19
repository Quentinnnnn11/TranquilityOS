#!/usr/bin/env bash
set -e


#SUDO !
if [ "$EUID" -ne 0 ]; then
  echo "Erreur : Ce script modifie les disques et doit être exécuté en tant qu'administrateur."
  echo "Veuillez relancer la commande avec sudo :"
  echo -e "\n    sudo tranquility-install\n"
  exit 1
fi

echo "=================================================="
echo "   BIENVENUE SUR L'INSTALLATEUR TRANQUILITY OS"
echo "=================================================="
echo ""
echo ""
echo ""


#BASIC
read -p "Nom d'hôte de la machine : " HOSTNAME
read -p "Nom de l'utilisateur local (administrateur local) local : " USERNAME
echo ""
echo "Le mot de passe doit contenir au moins 12 caractères, et doit être composé de :"
echo "  - au moins une lettre majuscule"
echo "  - au moins une lettre minuscule"
echo "  - au moins un chiffre"
echo "  - au moins un caractère spécial"
echo ""
while true; do
  read -s -p "Entrez le mot de passe : " USERPASS
  echo ""

  if ! echo "$USERPASS" | grep -qP '(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).{12,}'; then
    echo -e "\e[31mLe mot de passe ne respecte pas les critères de complexité.\e[0m\n"
    continue
  fi
  read -s -p "Confirmez le mot de passe : " USERPASS_CONFIRM
  echo ""

  if [ "$USERPASS" != "$USERPASS_CONFIRM" ]; then
    echo -e "\e[31mLes mots de passe ne correspondent pas. Veuillez réessayer.\e[0m\n"
    continue
  fi

  break
done


#RESEAU
clear
echo "=================================================="
echo "               CONFIGURATION RESEAU"
echo "=================================================="
echo ""
echo ""
echo ""
echo "Choisissez le mode de configuration réseau :"
echo "1) DHCP (Configuration automatique)"
echo "2) IP Fixe (Configuration statique)"

while true; do
  read -p "Votre choix : " NET_CHOICE
  case "$NET_CHOICE" in
    1)
      NET_MODE="dhcp"
      break
      ;;
    2)
      NET_MODE="static"
      echo ""
      echo "Interfaces réseau détectées sur cette machine :"
      ip -br link | grep -v "lo" | awk '{print "  - " $1 " (" $2 ")"}'
      echo ""
      
      read -p "Entrez le nom de l'interface à configurer (ex: enp0s3, eth0) : " NET_INT
      read -p "Adresse IP : " STATIC_IP
      read -p "Préfixe réseau CIDR (ex: 24 pour un masque 255.255.255.0) : " STATIC_PRFX
      read -p "Adresse IP de la passerelle par défaut : " STATIC_GW
      read -p "Adresse IP du serveur DNS : " STATIC_DNS
      break
      ;;
    *)
      echo -e "\e[31mChoix invalide. Veuillez réessayer.\e[0m\n"
      ;;
  esac
done


#AD
clear
echo "=================================================="
echo "          CONFIGURATION ACTIVE DIRECTORY"
echo "=================================================="
echo ""
echo ""
echo ""
read -p "Voulez-vous joindre cette machine à un domaine Active Directory ? (O/n) : " JOIN_AD

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
  read -p "Domaine Active Directory à rejoindre (ex: tranquility.local) : " AD_DOMAIN
  read -p "Adresse IP du serveur DNS lié à l'AD : " AD_DNS_IP
  read -p "Nom du compte AD à utiliser pour la jointure (ex: Administrateur) : " AD_ADMIN
  read -s -p "Mot de passe du compte AD à utiliser pour la jointure (sera supprimé après le premier démarrage) : " AD_ADMIN_PASS
fi


#DISQUES
clear
echo "==================================================="
echo "             PARTITIONNEMENT DU DISQUE"
echo "==================================================="
echo ""
echo "Vous allez être amené à séléctionner le disque à formatter."
echo "Un formattage sera ensuite automatiquement appliqué sur ce disque."
echo ""
echo ""
echo "DISQUES DISPONIBLES :"
lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop"

echo ""
echo "\e[31mATTENTION : TOUTES LES DONNÉES DU DISQUE CIBLE SERONT DÉTRUITES !\e[0m\n"
echo ""
read -p "Entrez le nom du disque à formater (ex: sda ou nvme0n1) : " DISK_NAME
read -p "Voulez-vous activer la prise en charge de l'hibernation ? (O/n) : " HIBERNATION
echo ""

if [[ $DISK_NAME == *nvme* ]]; then
  PART_SUFFIX="p"
else
  PART_SUFFIX=""
fi
TARGET_DISK="/dev/$DISK_NAME"

RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)

if [ "$RAM_GB" -eq 0 ]; then RAM_GB=1; fi

if [[ "$HIBERNATION" =~ ^[oO]$ ]]; then
  if [ "$RAM_GB" -le 4 ]; then
    SWAP_GB=$(( RAM_GB * 2 ))
  elif [ "$RAM_GB" -lt 32 ]; then
    SWAP_GB=$(( RAM_GB + 2 ))
  else
    SWAP_GB=$RAM_GB
  fi
  echo "Analyse matérielle : RAM détectée = ${RAM_GB} Go. Configuration d'un Swap de ${SWAP_GB} Go, avec hybernation."
else
  if [ "$RAM_GB" -le 2 ]; then
    SWAP_GB=$(( RAM_GB * 2 ))
  elif [ "$RAM_GB" -le 8 ]; then
    SWAP_GB=$RAM_GB
  else
    SWAP_GB=4
  fi
  echo "Analyse matérielle : RAM détectée = ${RAM_GB} Go. Configuration d'un Swap de ${SWAP_GB} Go, sans hybernation."
fi

EFI_END=512
SWAP_END=$(( EFI_END + (SWAP_GB * 1024) ))

echo "Nettoyage des anciens montages..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

echo "Nettoyage et création de la table de partitions GPT sur $TARGET_DISK..."
parted -s "$TARGET_DISK" -- mklabel gpt

echo "Création des partitions (EFI, Swap, Root)..."
parted -s "$TARGET_DISK" -- mkpart ESP fat32 1MiB ${EFI_END}MiB
parted -s "$TARGET_DISK" -- set 1 esp on
parted -s "$TARGET_DISK" -- mkpart swap linux-swap ${EFI_END}MiB ${SWAP_END}MiB
parted -s "$TARGET_DISK" -- mkpart primary ext4 ${SWAP_END}MiB 100%

echo "Synchronisation de la table de partitions..."
partprobe "$TARGET_DISK"
sleep 2

echo "Formatage de la partition de boot..."
mkfs.fat -F 32 -n boot "${TARGET_DISK}${PART_SUFFIX}1"

echo "Initialisation du SWAP..."
mkswap -L swap "${TARGET_DISK}${PART_SUFFIX}2"

echo "Formatage de la partition principale..."
echo ""
echo -e "\e[31mAttention : Le mot de passe de déchiffrement du disque va vous être demandé à plusieurs reprises.\e[0m\n"
echo ""
ROOT_PART="${TARGET_DISK}${PART_SUFFIX}3"
cryptsetup -q luksFormat "$ROOT_PART"
cryptsetup luksOpen "$ROOT_PART" cryptroot
mkfs.ext4 -F -q -L root /dev/mapper/cryptroot

echo "Attente de l'enregistrement des périphériques..."
udevadm settle
sleep 2

echo "Montage des partitions..."
swapon "${TARGET_DISK}${PART_SUFFIX}2"
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot


#CONFIGURATION
echo "Clonage du dépôt de configuration..."
rm -rf /mnt/etc/nixos
git clone https://github.com/Quentinnnnn11/TranquilityOS.git /mnt/etc/nixos

echo "Génération de la configuration hardware..."
nixos-generate-config --root /mnt

echo "Génération de l'identité de la machine..."
cat <<EOF > /mnt/etc/nixos/local-config.nix
{
  networking.hostName = "${HOSTNAME}";
EOF

if [ "$NET_MODE" = "dhcp" ]; then
cat <<EOF >> /mnt/etc/nixos/local-config.nix

  networking.dhcp = true;
EOF
else
cat <<EOF >> /mnt/etc/nixos/local-config.nix

  networking.dhcp = false;
  networking.interfaces.${NET_INT}.ipv4.addresses = [ {
    address = \"${STATIC_IP}\";
    prefixLength = ${STATIC_PRFX};
  } ];
  networking.defaultGateway = \"${STATIC_GW}\";
  networking.nameservers = [ \"${STATIC_DNS}\" ];"
EOF
fi


if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
cat <<EOF >> /mnt/etc/nixos/local-config.nix

  tranquility.ad.enable = true;
  tranquility.ad.domain = "${AD_DOMAIN}";
  tranquility.ad.dnsIp = "${AD_DNS_IP}";
  tranquility.ad.admin = "${AD_ADMIN}";
EOF
fi

cat <<EOF >> /mnt/etc/nixos/local-config.nix

  users.users.${USERNAME} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "${USERPASS}";
  };
}
EOF

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
  mkdir -p /mnt/root
  echo "${AD_ADMIN_PASS}" > /mnt/root/ad-pass.txt
  chmod 600 /mnt/root/ad-pass.txt
fi

echo "Intégration des fichiers locaux dans le registre git..."
cd /mnt/etc/nixos
git add -f hardware-configuration.nix
git add -f local-config.nix
cd -


#INSTALLATION
echo "Lancement de la compilation du système..."
nixos-install --no-root-passwd --flake /mnt/etc/nixos#TranquilityOS

echo "=================================================="
echo "Installation terminée avec succès !"
echo "Vous pouvez retirer la clé USB et redémarrer."
