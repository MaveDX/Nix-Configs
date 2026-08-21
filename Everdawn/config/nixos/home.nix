{ inputs, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ozgur";
  home.homeDirectory = "/home/ozgur";

  imports = [ 
    inputs.nixcord.homeModules.nixcord
    inputs.niri-scrollbar.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.zen-browser.homeModules.twilight
    inputs.niri-scrollbar.homeManagerModules.default
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  programs.spicetify =
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  enable = true;
  experimentalFeatures = true;
  spotifyLaunchFlags = "--enable-features=SharedArrayBuffer";

  enabledExtensions = with spicePkgs.extensions; [
    hidePodcasts
    shuffle # shuffle+ (special characters are sanitized out of extension names)
    fullAlbumDate
    volumePercentage
    aiBandBlocker
  ];

  enabledCustomApps = with spicePkgs.apps; [
    
  ];
  enabledSnippets = with spicePkgs.snippets; [
    pointer
    prettyLyrics
    removeUnusedSpace
    removeTheArtistsAndCreditsSectionsFromTheSidebar
    beSquare
    removeGradient
  ];

      #theme = spicePkgs.themes.sleek;
      #colorScheme = "Elementary";
  wayland = true;
};

   programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  stylix.targets.zen-browser.enable = false;
  stylix.targets.firefox.fonts.enable = false;
  stylix.targets.firefox.enable = false;

  services.niriScrollbar.enable = true;


  home.packages = [
    pkgs.ueberzugpp 
    pkgs.r2modman

  ];

#     systemd.user.services.gpu-screen-recorder = {
#     Unit = {
#       Description = "GPU Screen Recorder replay buffer";
#       After = "graphical-session.target";
#   };
#   Install = {
#     WantedBy = [ "graphical-session.target" ];
#   };
#   Service = {
#     Environment = [
#       "WAYLAND_DISPLAY=wayland-1"
#       "XDG_RUNTIME_DIR=/run/user/1000"
#     ];
#     ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w portal -c mp4 -k av1 -q medium -r 20 -o %h/Videos/Clips -a default_output";
#     Restart = "on-failure";
#     RestartSec = "5s";
#   };
# };

  home.pointerCursor = {
    gtk.enable = true;                     
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;                             
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };


  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };


  programs.nixcord = {
  enable = true;
  discord.vencord.enable = true;
  openASAR.enable = true;
  config = {
    frameless = true;
    transparent = true;

    themeLinks = [
      # "https://example.com/theme.css"
    ];
    plugins = {
      silentTyping.enable = true;
      ClearURLs.enable = true;
      fakeNitro.enable = true;
      volumeBooster.enable = true;
      webScreenShareFixes.enable = true;
      
    };
  };
    discord.commandLineArgs = [
    "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
    "--ozone-platform=wayland"
  ];
};


  xdg.configFile."environment.d/10-vulkan.conf".text = ''
  VK_ADD_DRIVER_FILES=${pkgs.addDriverRunpath.driverLink}/share/vulkan/icd.d
'';

  home.sessionVariables.VK_ADD_DRIVER_FILES = "${pkgs.addDriverRunpath.driverLink}/share/vulkan/icd.d";
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    # org.gradle.console=verbose
    # org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
