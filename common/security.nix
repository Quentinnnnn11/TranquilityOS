{ config, pkgs, ... }:

{
  services.usbguard = {
    enable = true;
    
    IPCAllowedGroups = [ "wheel" ];
    
    rules = ''
      # autoriser les hubs internes (ports usb)
      allow with-interface equals { 09:00:* }
      
      # autoriser les claviers et souris
      allow with-interface equals { 03:*:* }
      
      # bloquer tout le reste
      block
    '';
  };
}