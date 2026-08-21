{ inputs, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ozgur";
  home.homeDirectory = "/home/ozgur";

  imports = [ inputs.nixcord.homeModules.nixcord ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.
 

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.ueberzugpp 
    pkgs.r2modman

  ];

  # Cursor setup - Bibata-Modern-Ice (white, rounded, sexy clean look)
  home.pointerCursor = {
    gtk.enable = true;                     # Makes GTK (and most apps) actually fucking respect it
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;                             # Bump to 28/32 if you want it thicker on HiDPI
  };

  # Extra insurance for GTK apps to stop ignoring shit
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };


  # Force it via env vars too — some stubborn apps need the extra kick
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    # EDITOR = "emacs";   # (your original one is still here if you want it)
  };

  programs.steam.theme=pkgs.millenniumThemes.atoms;

  programs.nixcord = {
  enable = true;
  discord.vencord.enable = true;
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
    };
  };
};
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
