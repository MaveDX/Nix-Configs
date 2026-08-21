{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    

    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };

    nvf.url = "github:notashelf/nvf";

    niri-nix = {
     url = "git+https://codeberg.org/BANanaD3V/niri-nix";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";


    nix-index-database = {
       url = "github:nix-community/nix-index-database";
       inputs.nixpkgs.follows = "nixpkgs";
    };


    nixcord.url = "github:FlameFlag/nixcord";
    

    zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };

  };

    niri-scrollbar.url = "github:MaveDX/Niri-Scrollbar"; 

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  
  };

  outputs = { self, nixpkgs, nvf, nix-index-database, mangowm, stylix, chaotic, ... }@inputs: {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations.Duskveil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
          {
          nixpkgs.overlays = [
            inputs.millennium.overlays.default
            inputs.niri-nix.overlays.niri-nix
            
          ];
        }

        ./configuration.nix
        inputs.home-manager.nixosModules.default
        nvf.nixosModules.default
        nix-index-database.nixosModules.default
        mangowm.nixosModules.mango
        stylix.nixosModules.stylix
        chaotic.nixosModules.default
      
      ];
    };
  };
}
