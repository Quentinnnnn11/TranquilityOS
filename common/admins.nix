{ config, pkgs, ... }:

{
  security.sudo = {
    enable = true;
    
    execWheelOnly = true; 

    extraRules = [
      # {
      #   groups = [ "gg_linux_admins" ]; 
      #   commands = [
      #     {
      #       command = "ALL";
      #       options = [ "SETENV" ];
      #     }
      #   ];
      # }
    ];
  };
}