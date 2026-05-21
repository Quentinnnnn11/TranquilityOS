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

  # https://messervices.cyber.gouv.fr/documents-guides/fr_np_linux_configuration-v2.0.pdf
  # 5.2.1 - R8, R10
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

  # https://messervices.cyber.gouv.fr/documents-guides/fr_np_linux_configuration-v2.0.pdf
  # 5.2.2 - R9, R10, R11, R14
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.pid_max" = 65536;
    "kernel.perf_cpu_time_max_percent" = 1;
    "kernel.perf_event_max_sample_rate" = 1;
    "kernel.perf_event_paranoid" = 2;
    "kernel.randomize_va_space" = 2;
    "kernel.sysrq" = 0;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.panic_on_oops" = 1;
    "kernel.yama.ptrace_scope" = 2; #si utilisateurs dev, passer à 1
    "fs.suid_dumpable" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
  };

  # https://messervices.cyber.gouv.fr/documents-guides/fr_np_linux_configuration-v2.0.pdf
  # 6.1 - R28
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "hidepid=2" ];
  };
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "nosuid" "nodev" "noexec" "mode=1777" ];
  };
  fileSystems."/boot" = {
    options = [ "nosuid" "nodev" "noexec" ];
  };
  fileSystems."/var/tmp" = {
    device = "/var/tmp";
    fsType = "none";
    options = [ "bind" "nosuid" "nodev" "noexec" ];
    depends = [ "/" ];
  };
  fileSystems."/home" = {
    device = "/home";
    fsType = "none";
    options = [ "bind" "nosuid" "nodev" ];
    depends = [ "/" ];
  };
  fileSystems."/var" = {
    device = "/var";
    fsType = "none";
    options = [ "bind" "nosuid" "nodev" ];
    depends = [ "/" ];
  };
  fileSystems."/var/log" = {
    device = "/var/log";
    fsType = "none";
    options = [ "bind" "nosuid" "nodev" "noexec" ];
    depends = [ "/var" ]; 
  };
  fileSystems."/srv" = {
    device = "/srv";
    fsType = "none";
    options = [ "bind" "nosuid" "nodev" "noexec" ];
    depends = [ "/" ];
  };

  # https://messervices.cyber.gouv.fr/documents-guides/fr_np_linux_configuration-v2.0.pdf
  # 6.3.1 - R36
  environment.shellInit = ''
    umask 0077
  '';
  systemd.settings.Manager = {
    DefaultUMask = "0027";
  };
}