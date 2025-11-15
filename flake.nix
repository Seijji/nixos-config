{
  description = "A minimal flake.nix for a NixOS machine";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";  # Add this line
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, chaotic, home-manager, ... }@inputs:

  let
    system = "x86_64-linux";
    # Use stable nixpkgs just for Cryptomator
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.seeji = ./home/home.nix;
        }
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            # Use Cryptomator from stable channel
            pkgs-stable.cryptomator
          ];
        })
      ];
    };
  };
}
