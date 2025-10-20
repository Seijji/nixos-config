{
  description = "A minimal flake.nix for a NixOS machine";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs version
    };
  };
  outputs = {self, nixpkgs, auto-cpufreq, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Assumes a standard x86 CPU
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          auto-cpufreq.nixosModules.default
        ];
      };
    };
  };
}
