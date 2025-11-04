# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/fonts.nix
    ];

  # Home manager
  home-manager.backupFileExtension = "backup";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "GENERIC_V3"; };
  boot.kernelParams = [ "amd_pstate=active" ];
  powerManagement.enable = true;

  # SCX
  # services.scx.enable = true;
  # services.scx.scheduler = "scx_lavd";

  services.power-profiles-daemon.enable = true;

  # Enable zram swap
  zramSwap.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  
  # KDE
  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true; 

  # Virtualization
  virtualisation.vmware.host.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "fi";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;               # enable CUPS printing service
    cups-pdf.enable = true;      # enable the virtual PDF printer
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.seeji = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "gamemode" "openrazer" "plugdev" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Firefox
  programs.firefox = {
    enable = true;
    policies.DisableTelemetry = true;
  };

  # Shell
  users.users.seeji.shell = pkgs.zsh;
  programs.zsh.enable = true;

  # VDPAU VAAPI
  # Enable OpenGL/graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For 32-bit applications
    
    extraPackages = with pkgs; [
      vaapiVdpau      # VDPAU backend for VAAPI
      libvdpau-va-gl  # VDPAU driver with VA-GL backend
      rocmPackages.clr.icd  # OpenCL support (optional)
    ];
  };
  # Set environment variables for applications
  environment.variables = {
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Udev
  services.udev.packages = [ pkgs.headsetcontrol ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # OpenRazer
  hardware.openrazer.enable = true;

  # Overlays
  #nixpkgs.overlays = [ (import ./overlays/zettlr.nix) ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nano
    wget
    p7zip
    hyfetch
    alacritty
    btop
    htop
    macchina
    openrazer-daemon
    polychromatic
    nvd
    unzip
    neovim
    pdftk
    zoom-us
    nemo-fileroller
    # hunspell
    # hunspellDicts.sv_FI
    pandoc
    duf
    nil
    gh
    gimp
    libvoikko
    deja-dup
    claude-code
    chromium
    headsetcontrol
    cryptomator
    kdePackages.kcalc
    #zettlr
    (pkgs.callPackage ./pkgs/elan/elan.nix {})
    (pkgs.callPackage ./pkgs/zettlr/zettlr.nix {})
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

