{ config, pkgs, lib, ... }:

let
  user = "ozgur";
  group = "users";
  musicDir = "/mnt/Media/music";
in
{
  # ---------------------------------------------------------------------------
  # 1. Storage & State Directory Permissions (Declarative)
  # ---------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d ${musicDir} 0775 ${user} ${group} -"
    "d ${musicDir}/.incomplete 0775 ${user} ${group} -"
    "Z ${musicDir} 0775 ${user} ${group} -"
    # Capital 'Z' recursively transfers ownership of navidrome.db and cache to ozgur:
    "d /var/lib/slskd 0775 ${user} ${group} -"
    "Z /var/lib/slskd 0775 ${user} ${group} -"
    "d /var/lib/navidrome 0775 ${user} ${group} -"
    "Z /var/lib/navidrome 0775 ${user} ${group} -"
  ];

  # ---------------------------------------------------------------------------
  # 2. Search & Download: slskd (Runs as your user)
  # ---------------------------------------------------------------------------
  services.slskd = {
    enable = true;
    user = user;
    group = group;
    openFirewall = false;
    environmentFile = "/dev/null"; # Required by NixOS module to evaluate cleanly
    settings = {
      web.port = 5030;

      # Downloads go directly to your music directory as your user
      directories = {
        download = musicDir;
        incomplete = "${musicDir}/.incomplete";
      };

      # Auto-share your music library to pass Soulseek share checks
      shares.dirs = [
        musicDir
      ];

      flags = {
        file_permission = 664;
        folder_permission = 775;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 3. Streaming Server: Navidrome (Runs as your user)
  # ---------------------------------------------------------------------------
  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      Address = "100.83.72.56"; # Binds safely without boot-time Tailscale race conditions
      Port = 4533;
      MusicFolder = musicDir;
      DataFolder = "/var/lib/navidrome";
      ScanInterval = "1m"; # Fixed: 'ScanSchedule' is deprecated/ignored in Navidrome
      SessionTimeout = "24h";
      CoverArtPriority = "cover.*, folder.*, front.*, embedded";
    };
  };

  # Force Navidrome systemd service to run as your user
  systemd.services.navidrome = {
    serviceConfig = {
      User = lib.mkForce user;
      Group = lib.mkForce group;
    };
  };


  # ---------------------------------------------------------------------------
  # 4. Handy Desktop & CLI Utilities
  # ---------------------------------------------------------------------------
  environment.systemPackages = [
    pkgs.ffmpeg
    pkgs.nicotine-plus # Desktop GUI Soulseek client
    pkgs.spotdl        # CLI Spotify ripper
    pkgs.picard        # MusicBrainz Picard GUI tagger
  ];

  # Soulseek P2P port for fast peer connections
  networking.firewall.allowedTCPPorts = [ 2234 ];
}
