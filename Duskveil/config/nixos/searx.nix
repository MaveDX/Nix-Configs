{ config, pkgs, lib, ... }:

{
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;  # caching backend, recommended even solo

    environmentFile = "/home/ozgur/.config/searxng/.searxng.env";  # or plain path if not using sops/agenix

    settings = {
      general = {
        debug = false;
        instance_name = "Moonlit";
        donation_url = false;
        contact_url = false;
        privacypolicy_url = false;
        enable_metrics = false;
      };

      ui = {
        static_use_hash = true;
        default_locale = "en";
        query_in_title = true;
        infinite_scroll = true;
        center_alignment = false;
        default_theme = "simple";
        theme_args.simple_style = "auto";  # respects light/dark
      };

      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
        autocomplete_min = 2;
        ban_time_on_fail = 5;
        max_ban_time_on_fail = 120;
      };

      server = {
        bind_address = "100.83.72.56";
        port = 8888;
        secret_key = "@SEARXNG_SECRET@";  # comes from environmentFile
        limiter = false;  # you're the only user, no need to rate-limit yourself
        public_instance = false;
        image_proxy = true;
        method = "GET";
      };

      # Weight toward DDG-flavored results per what you asked for,
      # keep Google Images on, trim the categories you won't use
      engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
        "duckduckgo".disabled = false;
        "duckduckgo".weight = 5.0;
        "google".disabled = true;
        "brave".disabled = false;
        "brave".weight = 2.0;
        "bing".disabled = true;

        "google images".disabled = false;
        "bing images".disabled = false;
        "duckduckgo images".disabled = false;

        "google videos".disabled = false;
        "youtube".disabled = false;

        # maps: OSM/Nominatim is the realistic option here, as discussed
        "openstreetmap".disabled = false;

        "wikipedia".disabled = false;
        "github".disabled = false;
      };

      outgoing = {
        request_timeout = 5.0;
        max_request_timeout = 15.0;
        pool_connections = 100;
        pool_maxsize = 15;
        enable_http2 = true;
      };

      enabled_plugins = [
        "Basic Calculator"
        "Hash plugin"
        "Tracker URL remover"
        "Unit converter plugin"
        "Hostnames plugin"
      ];
    };
  };
}
