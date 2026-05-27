{ config, pkgs, ... }:

{
  security.sudo = {
    enable = true;
    
    execWheelOnly = false; 

    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [ { command = "ALL"; options = [ "SETENV" ]; } ];
      }

      {
        groups = [ "gg_linux_admins" ]; 
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl status \"\"";
            options = [ "NOEXEC" ];
          }
        ];
      }
    ];
  };
}