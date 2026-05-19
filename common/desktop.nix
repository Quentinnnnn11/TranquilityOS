{ config, pkgs, ... }:

let
  tranquilityWallpaper = ../assets/wallpaper.png;
  initWallpaperScript = pkgs.writeShellScriptBin "init-tranquility-wallpaper" ''
    FLAG_FILE="$HOME/.config/tranquility_wallpaper_initialized"

    if [ ! -f "$FLAG_FILE" ]; then
      sleep 5
      ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage ${tranquilityWallpaper}
      touch "$FLAG_FILE"
    fi
  '';
in

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = [ initWallpaperScript ];
  environment.etc."xdg/autostart/init-tranquility-wallpaper.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=${initWallpaperScript}/bin/init-tranquility-wallpaper
    Hidden=false
    NoDisplay=false
    Name=Initialisation du fond d'écran TranquilityOS
    Comment=Applique le fond d'écran par défaut à la création du profil
  '';

  environment.etc."xdg/menus/applications-merged/lasuite.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
    <Menu>
      <Name>Applications</Name>
      <Menu>
        <Name>LaSuite</Name> 
        <Directory>lasuite.directory</Directory>
        <Include>
          <Category>LaSuite</Category>
        </Include>
      </Menu>
    </Menu>
  '';

  console.keyMap = "fr";
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
