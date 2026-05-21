{ config, pkgs, ... }:

{
  # ORPHELINS
  systemd.services.audit-fichiers-orphelins = {
    description = "Recherche des fichiers sans propriétaire";
    
    script = ''
      ${pkgs.findutils}/bin/find / \
        -path /nix/store -prune -o \
        -path /proc -prune -o \
        -path /sys -prune -o \
        -type f \( -nouser -o -nogroup \) \
        -exec ${pkgs.systemd}/bin/logger -p authpriv.warning -t AUDIT-ORPHELIN "Alerte de sécurité : Fichier orphelin trouvé -> {}" \;
    '';
    
    serviceConfig = {
      Type = "oneshot";
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
    };
  };

  systemd.timers.audit-fichiers-orphelins = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true; 
    };
  };

  # UPDATES
  systemd.services.tranquility-upgrade = {
    description = "Mise a jour automatique de TranquilityOS";

    path = with pkgs; [
      coreutils
      git
      nix
      config.system.build.nixos-rebuild
    ];
    
    script = ''
      echo "Début de la mise à jour automatique..."
      
      cd /etc/nixos
      
      echo "Synchronisation avec le dépôt Git..."
      git pull origin main
      
      echo "Recompilation de Tranquility OS..."
      nixos-rebuild switch --flake .#TranquilityOS
      
      echo "Mise à jour terminée avec succès !"
    '';
    
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.tranquility-upgrade = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 04:00:00";
      Persistent = true; 
    };
  };
}