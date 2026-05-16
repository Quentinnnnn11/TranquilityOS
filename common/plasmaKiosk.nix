{
  #environment.etc."xdg/kdeglobals".text = ''
  #  [KDE Action Restrictions][$i]
  #  plasma/plasmashell/unlockedDesktop=false
  #  plasma/plasma-desktop/scripting=false
  #'';

  environment.etc."xdg/kscreenlockerrc".text = ''
    [Daemon][$i]
    Autolock=true
    Timeout=5
    LockOnResume=true
    LockGrace=0
    RequirePassword=true
  '';
}
