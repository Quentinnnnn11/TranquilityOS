{ config, pkgs, lib, ... }:

let
  cfg = config.tranquility.ad;
in

{
  options.tranquility.ad = {
    enable = lib.mkEnableOption "Intégration Active Directory";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Le nom de domaine AD à rejoindre";
    };
    dnsIp = lib.mkOption {
      type = lib.types.str;
      description = "L'adresse IP du DNS principal";
    };
     admin = lib.mkOption {
      type = lib.types.str;
      description = "Le nom du compte à utiliser pour la jointure";
    };
  };

  config = lib.mkIf cfg.enable {

    # DNS
    networking.search = [ cfg.domain ];
    networking.nameservers = mkForce [ cfg.dnsIp ]; 

    # OUTILS AD
    environment.systemPackages = with pkgs; [ adcli sssd krb5 ];
  
    # SSSD (GESTION AUTHENT)
    services.sssd = {
      enable = true;
      config = ''
        [sssd]
        config_file_version = 2
        services = nss, pam
        domains = ${cfg.domain}

        [domain/${cfg.domain}]
        id_provider = ad
        access_provider = ad
        use_fully_qualified_names = False
        fallback_homedir = /home/%d/%u
        cache_credentials = True
        override_shell = ${pkgs.bashInteractive}/bin/bash
      '';
    };

    # PAM
    security.pam.services.login.makeHomeDir = true;
    security.pam.services.sddm.makeHomeDir = true;

    # ENROLEMENT
    systemd.services.adcli-auto-join = {
      description = "Enrolement automatique à l'AD";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig = {
        ConditionPathExists = "!/etc/krb5.keytab";
      };    
      serviceConfig = {
        Type = "oneshot";
        ExecCondition = "${pkgs.coreutils}/bin/test -f /root/ad-pass.txt";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.adcli}/bin/adcli join -D ${cfg.domain} -U ${cfg.admin} --stdin-password < /root/ad-pass.txt'";
        ExecStartPost = "${pkgs.coreutils}/bin/rm -f /root/ad-pass.txt";
        ExecStopPost = "${pkgs.systemd}/bin/systemctl restart sssd";
      };
    };
  };
}
