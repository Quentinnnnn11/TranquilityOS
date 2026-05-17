#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo " Erreur : Ce script modifie les disques et doit être exécuté en tant qu'administrateur."
  echo " Veuillez relancer la commande avec sudo :"
  echo -e "\n    sudo tranquility-install\n"
  exit 1
fi

echo "=================================================="
echo "   BIENVENUE SUR L'INSTALLATEUR TRANQUILITY OS"
echo "=================================================="

read -p " Nom d'hôte (Hostname) de la machine : " HOSTNAME
read -p " Nom de l'utilisateur local : " USERNAME
read -s -p " Mot de passe de l'utilisateur local : " USERPASS
echo ""

echo "=================================================="
read -p " Voulez-vous joindre cette machine à un domaine Active Directory ? (o/N) : " JOIN_AD

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
  echo "--- Configuration Active Directory ---"
  read -p " Domaine Active Directory à rejoindre (ex: tranquility.local) : " AD_DOMAIN
  read -p " IP du serveur DNS principali (ex: 192.168.1.100) : " AD_DNS_IP
  read -p " Nom du compte AD à utiliser pour la jointure (ex: Administrateur) : " AD_ADMIN
  read -s -p " Mot de passe du compte AD à utiliser pour la jointure (sera supprimé après le premier démarrage) : " AD_ADMIN_PASS
  echo ""
fi

echo "=================================================="
echo " DISQUES DISPONIBLES :"
lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop"

echo ""
echo " ATTENTION : TOUTES LES DONNÉES DU DISQUE CIBLE SERONT DÉTRUITES !"
read -p " Entrez le nom du disque à formater (ex: sda ou nvme0n1) : " DISK_NAME
read -p " Voulez-vous activer la prise en charge de l'hibernation ? (o/N) : " HIBERNATION

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
  echo " Analyse matérielle : RAM détectée = ${RAM_GB} Go. Configuration d'un Swap de ${SWAP_GB} Go, avec hybernation."
else
  if [ "$RAM_GB" -le 2 ]; then
    SWAP_GB=$(( RAM_GB * 2 ))
  elif [ "$RAM_GB" -le 8 ]; then
    SWAP_GB=$RAM_GB
  else
    SWAP_GB=4
  fi
  echo " Analyse matérielle : RAM détectée = ${RAM_GB} Go. Configuration d'un Swap de ${SWAP_GB} Go, sans hybernation."
fi

EFI_END=512
SWAP_END=$(( EFI_END + (SWAP_GB * 1024) ))

echo " Nettoyage et création de la table de partitions GPT sur $TARGET_DISK..."
parted -s "$TARGET_DISK" -- mklabel gpt

echo " Création des partitions (EFI, Swap, Root)..."
parted -s "$TARGET_DISK" -- mkpart ESP fat32 1MiB ${EFI_END}MiB
parted -s "$TARGET_DISK" -- set 1 esp on
parted -s "$TARGET_DISK" -- mkpart swap linux-swap ${EFI_END}MiB ${SWAP_END}MiB
parted -s "$TARGET_DISK" -- mkpart primary ext4 ${SWAP_END}MiB 100%

echo " Formatage des systèmes de fichiers..."
mkfs.fat -F 32 -n boot "${TARGET_DISK}${PART_SUFFIX}1"
mkswap -L swap "${TARGET_DISK}${PART_SUFFIX}2"
mkfs.ext4 -F -L root "${TARGET_DISK}${PART_SUFFIX}3"

echo " Montage des partitions..."
swapon "${TARGET_DISK}${PART_SUFFIX}2"
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

echo " Clonage du dépôt de configuration..."
git clone https://github.com/Quentinnnnn11/TranquilityOS.git /mnt/etc/nixos

nixos-generate-config --root /mnt

echo " Génération de l'identité de la machine..."
cat <<EOF > /mnt/etc/nixos/local-config.nix
{
  networking.hostName = "${HOSTNAME}";

  users.users.${USERNAME} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "${USERPASS}";
  };
EOF

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
cat <<EOF >> /mnt/etc/nixos/local-config.nix

  tranquility.ad.enable = true;
  tranquility.ad.domain = "${AD_DOMAIN}";
  tranquility.ad.dnsIp = "${AD_DNS_IP}";
  tranquility.ad.admin = "${AD_ADMIN}";
EOF
fi

cat <<EOF >> /mnt/etc/nixos/local-config.nix
}
EOF

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
  mkdir -p /mnt/root
  echo "${AD_ADMIN_PASS}" > /mnt/root/ad-pass.txt
  chmod 600 /mnt/root/ad-pass.txt
fi

echo " Lancement de la compilation du système..."
nixos-install --flake /mnt/etc/nixos#TranquilityOS

echo "=================================================="
echo " Installation terminée avec succès !"
echo " Vous pouvez retirer la clé USB et redémarrer."
