{
  description = "A minimal flake.nix for a NixOS machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zettlr-flake.url = "path:./pkgs/zettlr-flake";
  };

  outputs = { self, nixpkgs, chaotic, home-manager, zettlr-flake, ... }@inputs:
  let
    system = "x86_64-linux";  # ← define it here, once
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
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

            environment.systemPackages = [
              zettlr-flake.packages.${system}.zettlr-beta
            ];
          }
        ];
      };
    };

    # optional shortcut: allow `nix run .#zettlr-beta`
    packages.${system}.zettlr-beta = zettlr-flake.packages.${system}.zettlr-beta;
  };
}
