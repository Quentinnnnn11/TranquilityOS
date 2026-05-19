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
    firefox
    remmina #RDP
    p7zip
    unzip
    unrar
    vlc
    obsidian
    libqalculate
    noisetorch #reduction de bruit pour micro
    gnome-power-manager
    chromium

    #LaSuite
    (makeDesktopItem {
      name = "lasuite-tchap";
      desktopName = "Tchap - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://www.tchap.gouv.fr";
      icon = "${./assets/tchap.svg}";
    })
    (makeDesktopItem {
      name = "lasuite-visio";
      desktopName = "Visio - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/visio";
      icon = "${./assets/visio.svg}";
    })
    (makeDesktopItem {
      name = "lasuite-docs";
      desktopName = "Docs - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/docs";
      icon = "${./assets/docs.svg}";
    })
    (makeDesktopItem {
      name = "lasuite-grist";
      desktopName = "Grist - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/grist";
      icon = "${./assets/grist.svg}";
    })
    (makeDesktopItem {
      name = "lasuite-fichiers";
      desktopName = "Fichiers - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://lasuite.numerique.gouv.fr/produits/fichiers";
      icon = "${./assets/fichiers.svg}";
    })
    (makeDesktopItem {
      name = "francetransfert-grist";
      desktopName = "FranceTransfert - LaSuite";
      exec = "${pkgs.chromium}/bin/chromium --app=https://francetransfert.numerique.gouv.fr/upload";
      icon = "${./assets/francetransfert.svg}";
    })
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
    kate
  ];
}
