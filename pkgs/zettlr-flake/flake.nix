{
  description = "Standalone flake for Zettlr beta build";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.zettlr-beta = pkgs.stdenv.mkDerivation rec {
      pname = "zettlr-beta";
      version = "3.2.0-beta"; # example, adjust

      src = pkgs.fetchFromGitHub {
        owner = "Zettlr";
        repo = "Zettlr";
        rev = "v${version}";
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # update this
      };

      nativeBuildInputs = [ pkgs.nodejs pkgs.yarn ];

      buildPhase = ''
        yarn install --frozen-lockfile
        yarn build
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp -r dist/linux-unpacked $out/opt/zettlr
        ln -s $out/opt/zettlr/zettlr $out/bin/zettlr
      '';

      meta = with pkgs.lib; {
        description = "A markdown editor for researchers (beta build)";
        homepage = "https://www.zettlr.com/";
        license = licenses.gpl3;
        maintainers = [ maintainers.yourname ];
        platforms = platforms.linux;
      };
    };
  };
}
