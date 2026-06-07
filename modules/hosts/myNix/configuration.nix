{ self, inputs, ... }: {

  flake.nixosModules.myNixConfiguration = { config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      self.nixosModules.myNixHardware
    ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  
  boot.kernelParams = [
    "zswap.enabled=0"
    "processor.max_cstate=1"
    "amd_pstate=passive"
    "pcie_aspm=off"
  ];


  networking.hostName = "Rog-NixOs"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  services.envfs.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kuala_Lumpur";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ms_MY.UTF-8";
    LC_IDENTIFICATION = "ms_MY.UTF-8";
    LC_MEASUREMENT = "ms_MY.UTF-8";
    LC_MONETARY = "ms_MY.UTF-8";
    LC_NAME = "ms_MY.UTF-8";
    LC_NUMERIC = "ms_MY.UTF-8";
    LC_PAPER = "ms_MY.UTF-8";
    LC_TELEPHONE = "ms_MY.UTF-8";
    LC_TIME = "ms_MY.UTF-8";
  };

   # NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users.users."imzaa" = {
    isNormalUser = true;
    description = "imzaa";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    
    ];
  };


  programs.firefox.enable = true;
  programs.niri.enable = true;
  programs.fish.enable = true;
  
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim
  wget
  git
  btop
  fastfetch
  steam
  discord
  bottles
  heroic
  lutris
  protonplus
  vscode
  bash
  coreutils
  findutils
  gnugrep
  gnused
  gawk
  procps
  xdg-utils
  glib
  kdePackages.kconfig
  wlsunset
  python3
  yt-dlp
  mpv
  socat
  fish
  niri
  xwayland-satellite
  quickshell
  kitty
  foot
  libreoffice-fresh
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
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.extraSpecialArgs = { inherit inputs self; };

home-manager.users."imzaa" = { pkgs, lib, ... }: {
  imports = [
    (self + /hm/inir-home.nix)
  ];

  home.stateVersion = "26.05";

  programs.inir.enable = true;
};

  system.stateVersion = "26.05";
};
}
