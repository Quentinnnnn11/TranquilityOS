{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  networking.hostName = "tranquility-installer";
  
  environment.systemPackages = [
    (pkgs.writeScriptBin "tranquility-install" (builtins.readFile ./iso/installer.sh))
  ];

  services.getty.helpLine = ''
    Bienvenue sur TranquilityOS !
    Pour lancer l'installation personnalisée de TranquilityOS,
    tapez simplement la commande suivante :
    
        tranquility-install
  '';
}
