{ config, pkgs, ... }:

{
  # DNS
  networking.search = [ "tranquility.local" ];
  networking.networkmanager.insertNameservers = [ "192.168.27.175" ]; 

  # OUTILS AD
  environment.systemPackages = with pkgs; [
    adcli
    sssd
    krb5
  ];
  
  # SSSD (GESTION AUTHENT)
  services.sssd = {
    enable = true;
    config = ''
      [sssd]
      config_file_version = 2
      services = nss, pam
      domains = tranquility.local

      [domain/tranquility.local]
      id_provider = ad
      access_provider = ad
      
      use_fully_qualified_names = False
      
      fallback_homedir = /home/%d/%u
      
      cache_credentials = True
    '';
  };

  # PAM
  security.pam.services.login.makeHomeDir = true;
  security.pam.services.sddm.makeHomeDir = true;

  # ENROLEMENT
  systemd.services.adcli-auto-join = {
    description = "Enrolement automatique à l'Active Directory";
    
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    unitConfig = {
      ConditionPathExists = "!/etc/krb5.keytab";
    };    

    serviceConfig = {
      Type = "oneshot";

      ExecCondition = "${pkgs.coreutils}/bin/test -f /root/ad-pass.txt";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.adcli}/bin/adcli join -D tranquility.local -U Administrateur --stdin-password < /root/ad-pass.txt'";
      ExecStartPost = "${pkgs.coreutils}/bin/rm -f /root/ad-pass.txt";
      ExecStopPost = "${pkgs.systemd}/bin/systemctl restart sssd";
    };
  };
}
