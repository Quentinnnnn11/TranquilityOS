{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    thunderbird
    remmina #RDP
    p7zip
    unzip
    unrar
    vlc
    libqalculate
    gnome-power-manager
    keepassxc

    #LaSuite
    (makeDesktopItem {
      name = "lasuite-tchap";
      desktopName = "Tchap - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://www.tchap.gouv.fr";
      icon = "${../assets/tchap.svg}";
      categories = [ "Network" ];
    })
    (makeDesktopItem {
      name = "lasuite-visio";
      desktopName = "Visio - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/visio";
      icon = "${../assets/visio.svg}";
      categories = [ "Network" ];
    })
    (makeDesktopItem {
      name = "lasuite-docs";
      desktopName = "Docs - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/docs";
      icon = "${../assets/docs.svg}";
      categories = [ "Office" ];
    })
    (makeDesktopItem {
      name = "lasuite-grist";
      desktopName = "Grist - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/grist";
      icon = "${../assets/grist.svg}";
      categories = [ "Office" ];
    })
    (makeDesktopItem {
      name = "lasuite-fichiers";
      desktopName = "Fichiers - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/fichiers";
      icon = "${../assets/fichiers.svg}";
      categories = [ "Office" ];
    })
    (makeDesktopItem {
      name = "francetransfert-grist";
      desktopName = "FranceTransfert - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://francetransfert.numerique.gouv.fr/upload";
      icon = "${../assets/francetransfert.svg}";
      categories = [ "Utility" ];
    })
  ];

  #Firefox
  programs.firefox = {
    enable = true;
    policies = {
      ExtensionSettings = {
        "keepassxc-browser@keepassxc.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
    };
  };

  #Chromium
  programs.chromium = {
    enable = true;
    extraOpts = {
      "PasswordManagerEnabled" = false;
      "BuiltInDataProtectionEnabled" = true;
      "BackgroundModeEnabled" = false;
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
    kate
    discover
  ];
}
