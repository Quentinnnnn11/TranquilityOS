{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  networking.hostName = "tranquility-installer";

  console.keyMap = "fr";
  
  environment.systemPackages = [
    (pkgs.writeScriptBin "tranquility-install" (builtins.readFile ./iso/installer.sh))
  ];

  services.getty.greetingLine = lib.mkForce "";

  services.getty.helpLine = lib.mkForce ''
    \e[1;36m
    =================================================================
               BIENVENUE SUR L'INSTALLATEUR TRANQUILITY OS
    =================================================================
    \e[0m
    
    Pour lancer l'installation personnalisée de TranquilityOS,
    tapez la commande suivante :
    
        \e[1;32msudo tranquility-install\e[0m
  '';

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
}
