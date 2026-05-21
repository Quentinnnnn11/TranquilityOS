{ config, pkgs, ... }:

{
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
}