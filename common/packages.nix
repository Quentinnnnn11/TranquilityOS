{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    libreoffice-qt
    hunspell
    hunspellDicts.fr-moderne
    thunderbird
    firefox
    remmina
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
    kate
  ];
}
