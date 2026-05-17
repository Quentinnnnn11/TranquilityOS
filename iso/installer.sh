#!/usr/bin/env bash
set -e

echo "=================================================="
echo "   BIENVENUE SUR L'INSTALLATEUR TRANQUILITY OS"
echo "=================================================="

read -p "Nom d'hôte (Hostname) de la machine : " HOSTNAME
read -p "Nom de l'utilisateur local : " USERNAME
read -s -p "Mot de passe de l'utilisateur local : " USERPASS
echo ""

echo "=================================================="
read -p "Voulez-vous joindre cette machine à un Active Directory ? (o/N) : " JOIN_AD

if [[ "$JOIN_AD" =~ ^[oO]$ ]]; then
  echo "--- Configuration Active Directory ---"
  read -p "Domaine Active Directory à rejoindre (ex: tranquility.local) : " AD_DOMAIN
  read -p "IP du serveur DNS principali (ex: 192.168.1.100) : " AD_DNS_IP
  read -p "Nom du compte AD à utiliser pour la jointure (ex: Administrateur) : " AD_ADMIN
  read -s -p "Mot de passe du compte AD à utiliser pour la jointure (sera supprimé après le premier démarrage) : " AD_ADMIN_PASS
  echo ""
fi

echo "Préparation du disque principal..."
# Ici tu mettras ta logique de partitionnement (parted, mkfs.ext4, etc.)
# Pour l'exemple, on suppose que la cible est montée sur /mnt

echo "Clonage du dépôt de configuration..."
git clone https://github.com/Quentinnnnn11/TranquilityOS.git /mnt/etc/nixos

nixos-generate-config --root /mnt

echo "Génération de l'identité de la machine..."
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

echo "Lancement de la compilation du système..."
nixos-install --flake /mnt/etc/nixos#TranquilityOS

echo "=================================================="
echo "Installation terminée avec succès !"
echo "Vous pouvez retirer la clé USB et redémarrer."
