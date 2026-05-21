{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./common/desktop.nix
      ./common/packages.nix
      ./common/print.nix
      ./common/plasmaKiosk.nix
      ./common/active-directory.nix
      ./common/security.nix
      ./common/admins.nix
      ./common/services.nix
      (if builtins.pathExists ./local-config.nix then ./local-config.nix else {})
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services.openssh.enable = true;

  system.stateVersion = "25.11";
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
