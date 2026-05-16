{ pkgs, ... }:

{
  services.printing.enable = true;
  services.printing.drivers = [
    # Add printer drivers here
  ];
}
