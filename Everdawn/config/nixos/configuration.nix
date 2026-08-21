# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    themeConfig = {
        background = "/run/sddm-wallpaper";
        FormPosition = "left";
        RoundCorners = "1";
        };

  };
in

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nixld.nix
      #inputs.spicetify-nix.nixosModules.default
      inputs.niri-nix.nixosModules.default
      inputs.noctalia-greeter.nixosModules.default
      #./searx.nix
    ];

  system.nixos.distroName = "Mave Linux";

  # Bootloader.
  boot.loader.limine.enable = true;
  boot.loader.limine.style = {
    wallpapers = [./peakpx.jpg];
  };
  
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  security.polkit.enable = true;
  security.polkit.enablePkexecWrapper = true;
  security.sudo-rs.enable = true;
  security.rtkit.enable = true;

  boot = {

    plymouth = {
      enable = true;
      #themePackages = [ pkgs.catppuccin-plymouth ];
      #theme = "catppuccin-macchiato";
    };


    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      #"splash"
      "boot.shell_on_fail"
      "udev.log_level=3"
      "systemd.show_status=auto"
      "split_lock_detect=off"
      "clearcpuid=umip" 
      "amdgpu.dcdebugmask=0x10"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed

  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelModules = [ "ntsync" "uinput" ];

  boot.extraModprobeConfig = ''
  options btusb enable_autosuspend=0
'';

  networking.hostName = "Everdawn"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  xdg.mime.enable = true;
  xdg.menus.enable = true;

xdg.portal = {
  enable = true;
  xdgOpenUsePortal = true;
  wlr.enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gnome
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];
  config = {
    niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
    common = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
  };
};    

    #systemd.services.sddm-wallpaper = {
    #description = "Pick random SDDM wallpaper";
    #wantedBy = [ "display-manager.service" ];
    #before = [ "display-manager.service" ];
    #serviceConfig.Type = "oneshot";
  #script = ''
  # WALLS=($(ls /etc/nixos/SDDM_Wallpapers/))
  # RANDOM_WALL=''${WALLS[$RANDOM % ''${#WALLS[@]}]}
    # ln -sf "/etc/nixos/SDDM_Wallpapers/$RANDOM_WALL" /run/sddm-wallpaper
    # '';
  #};

  #Enable Progams.
    #services.displayManager.sddm = {
    #enable = true;
    #settings.Theme.CursorTheme = "Bibata-Modern-Ice";
    #theme = "sddm-astronaut-theme";
    #extraPackages = [custom-sddm-astronaut];
    
  #};
  
  services.displayManager.defaultSession = "niri";
  services.dbus.enable = true;
  services.upower.enable = true;

  services.udev = {
    extraRules = ''
  KERNEL=="uinput", MODE="0660", GROUP="input"
'';
    packages = with pkgs; [
    qmk
    qmk-udev-rules # the only relevant
    qmk_hid
    via
    vial
  ];

  };


# Enable Services and Software

  services.udisks2.enable = true;
  services.jellyfin.enable = true;
  services.tailscale.enable = true;
  services.hardware.openrgb = {
    enable = true;
    startupProfile = "porple";
  };
  services.tailscale.useRoutingFeatures = "both";
  services.flatpak.enable = true;
  services.xserver.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };

 

services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;

 };

  services.pipewire.extraLadspaPackages = [ pkgs.rnnoise-plugin ];

services.pipewire.extraConfig.pipewire."00-ladspa-path" = {
  "context.properties" = {
    "ladspa.path" = "${pkgs.rnnoise-plugin}/lib/ladspa";
  };
};



services.pipewire.extraConfig.pipewire."99-noise-cancel" = {
  "context.modules" = [
    {
      name = "libpipewire-module-filter-chain";
      flags = [ "nofail" ];
      args = {
        "node.description" = "Noise Canceling source";
        "media.name" = "Noise Canceling source";
        "filter.graph" = {
          nodes = [
            {
              type = "ladspa";
              name = "rnnoise";
              plugin = "librnnoise_ladspa";
              label = "noise_suppressor_stereo";
              control = {
                "VAD Threshold (%)" = 50.0;
                "VAD Grace Period (ms)" = 200;
                "Retroactive VAD Grace (ms)" = 0;
              };
            }
          ];
        };
        "capture.props" = {
          "node.name" = "capture.rnnoise_source";
          "node.passive" = true;
          "audio.rate" = 48000;
        };
        "playback.props" = {
          "node.name" = "rnnoise_source";
          "media.class" = "Audio/Source";
          "audio.rate" = 48000;
        };
      };
    }
  ];
};

services.pipewire.extraConfig.pipewire."10-quantum" = {
  "context.properties" = {
    "default.clock.min-quantum" = 512;
  };
};

  hardware.keyboard.qmk.enable = true;

    #hardware.openrazer = {
    #enable = true;
    #batteryNotifier.percentage = 10;
    #batteryNotifier.frequency = 3600;
  #};

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  fonts.fontDir.enable = true;


  programs = {

  niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  #halley.enable = true;

  fish.enable = true;
  steam = {
    enable = true;
    package = pkgs.millennium-steam;
    extraPackages = with pkgs; [ noto-fonts-cjk-sans noto-fonts-cjk-serif wqy_zenhei ];
  };

  starship.enable = true;
  kdeconnect.enable = true;
  mango.enable = true;
  nix-index-database.comma.enable = true;
  firefox.enable = true;

  nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/ozgur/.config/nixos"; # sets NH_OS_FLAKE variable for you
  };

  noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";
  };

  gamescope = {
    enable = true;
    args = [
      "-w 2560"
      "-h 1440"
      "-W 2560"
      "-H 1440"
      "-r 165"
      "-f"
      "--adaptive-sync"
      ];
  };

  nvf = {
    enable = true;
    settings = {
      vim.theme.enable = true;
      vim.theme.name = "oxocarbon";
      vim.theme.style = "dark";
      vim.theme.transparent = true;

      vim.statusline.lualine.enable = true;
      vim.telescope.enable = true;
      vim.autocomplete.nvim-cmp.enable = true;
      vim.clipboard.enable = true;
      vim.formatter.conform-nvim.enable = true;
      vim.clipboard.providers.wl-copy.enable = true;
      vim.clipboard.providers.wl-copy.package = pkgs.wl-clipboard;
      vim.dashboard.dashboard-nvim.enable = true;
      vim.tabline.nvimBufferline.enable = true;
      vim.utility.snacks-nvim.enable = true;
      vim.autopairs.nvim-autopairs.enable = true;
      vim.binds.whichKey.enable = true;
      vim.visuals.cursorline.enable = true;
      vim.ui.fastaction.enable = true;
      vim.languages.enableTreesitter = true; 
      vim.treesitter.indent.enable = true;
      
      vim.lsp.enable = true;

      vim.languages.nix = {
        enable = true;
        extraDiagnostics = {
                enable = true;
                types = ["statix" "deadnix"];
                                };
                        };
      vim.languages.rust.enable = true;
      vim.languages.python.enable = true;

      vim.options = {
  # These control the behavior of the "Enter" key and spacing
        autoindent = true;   # Copy indent from current line when starting a new line
        smartindent = true;  # Insert indents automatically based on syntax (e.g., after '{')
        shiftwidth = 2;      # Number of spaces to use for each step of indent
        tabstop = 2;         # Number of spaces that a <Tab> counts for
        expandtab = true;    # Use spaces instead of tabs
        };

      };
    };

  };

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";
    override = {
      base00 = "191919";
      base01 = "1e1e1e";
      base02 = "191919";
      base08 = "1e1e1e";

    };

    targets = {

      qt.enable = false;
      nvf.enable = false;
      fish.enable = false;
      font-packages.enable = false;
      font-packages.fonts.enable = false;

      };
  };

  fileSystems."/mnt/SataSSD" = {
  	device = "/dev/disk/by-label/SataSSD";
	fsType = "ext4";
	options = [
		"nofail"
		"nosuid"
		"nodev"
		"x-gvfs-show"
		];
	};

  fileSystems."/mnt/NVME" = {
  	device = "/dev/disk/by-label/NVME";
	fsType = "btrfs";
	options = [
	  "compress=zstd:3"
		"nofail"
		"nosuid"
		"nodev"
		"x-gvfs-show"
		];
	};

  fileSystems."/mnt/Media" = {
  	device = "/dev/disk/by-label/Media";
	fsType = "ext4";
	options = [
		"nofail"
		"nosuid"
		"nodev"
		"x-gvfs-show"
		];
	};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto";
    trusted-users = ["root" "ozgur"];
    substituters = [
      "https://niri-nix.cachix.org"
      "https://noctalia.cachix.org" 
      "https://nyx-cache.chaotic.cx/"
    ];
    trusted-public-keys = [
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
};

home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = { inherit inputs; };
  users.ozgur = import ./home.nix;
  backupFileExtension = "bak";
};


  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ozgur = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Ozgur Yigit";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "openrazer" "input"];
    packages = with pkgs; [
    ];
  };

   users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };
  users.groups.greeter = {};


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.etc."xdg/menus/applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # Install Stuff
  
  environment.systemPackages = with pkgs; [
    fastfetch
    ghostty
    kitty
    python314Packages.pip
    neovim
    protonplus
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    git
    yazi
    sddm-astronaut
    kdePackages.qtmultimedia
    btop-rocm
    yt-dlp
    wl-clipboard
    faugus-launcher
    gnome-disk-utility
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    mpv
    playerctl
    cava
    quickshell
    pywal
    python314
    pywalfox-native
    mangohud
    obsidian
    qbittorrent
    wget
    unzip
    p7zip
    cargo
    home-manager
    qt6Packages.qt6ct
    xdg-desktop-portal-gtk
    python3Packages.opencv4
    libreoffice-still
    zed-editor
    clinfo
    rocmPackages.rocminfo
    rocmPackages.rocm-runtime
    rocmPackages.hipcc
    rocmPackages.clr
    rocmPackages.rocm-smi
    ocl-icd
    kdePackages.filelight
    kdePackages.dolphin
    kdePackages.plasma-workspace
    kdePackages.qttools 
    kdePackages.ark
    kdePackages.kio-extras
    ffmpegthumbnailer
    unrar
    qimgv
    krita
    bibata-cursors
    openrazer-daemon
    heroic
    goverlay
    nix-init
    vivaldi
    nautilus
    distrobox
    ryubing
    rnnoise-plugin
    prismlauncher
    podman-compose
    kdePackages.isoimagewriter
    jq
    custom-sddm-astronaut
    grim
    slurp
    wayfreeze
    ags
    whatsie
    zip
    gparted
    socat
    xwayland-satellite
    opencode-desktop
    opencode
    github-cli
    janet
    jpm
    zig
    inputs.rill.packages.${system}.default
    river


  ];
 
 fonts.packages = with pkgs; [
  maple-mono.NF
  ibm-plex
	noto-fonts
	noto-fonts-cjk-sans
  noto-fonts-cjk-serif
  noto-fonts-color-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  dina-font
  proggyfonts
  wqy_zenhei
  corefonts
  ];

  environment.sessionVariables = {
  	EDITOR = "nvim";
  	VISUAL = "nvim";
  	SUDO_EDITOR = "nvim";
    TERMINAL = "ghostty";
    MLFG_UPGRADE = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    SDL_VIDEODRIVER = "wayland";
    WLR_DRM_NO_ATOMIC = "1";
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
};

  virtualisation.oci-containers.backend = "podman";

virtualisation.oci-containers.containers.shoko-server = {
  image = "docker.io/shokoanime/server:latest";
  volumes = [
    "/var/lib/shoko/config:/home/shoko/.shoko"
    "/mnt/Media/Anime:/Anime"
  ];
  ports = [ "8111:8111" ];
  extraOptions = [ "--pull=newer" ];
};



  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8384 13305 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
