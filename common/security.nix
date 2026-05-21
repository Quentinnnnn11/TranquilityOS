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

boot.kernelParams = [
  "pti=on"
  "spectre_v2=on"
  "spec_store_bypass_disable=seccomp"
  "page_poison=on"
  "slab_nomerge=yes"
  "slub_debug=FZP"
  "page_alloc.shuffle=1"
  "mce=0"
  "rng_core.default_quality=500"
  "mds=full"
];
}