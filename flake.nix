{
  description = "A minimal flake.nix for a NixOS machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Local Zettlr flake
    zettlr-flake.url = "path:./pkgs/zettlr-flake";
  };

  outputs = { self, nixpkgs, chaotic, home-manager, zettlr-flake, ... }@inputs:
  let
    system = "x86_64-linux";
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

          environment.systemPackages = with inputs; [
            zettlr-flake.packages.${system}.zettlr-beta
          ];
        }
      ];
    };
  };
}
