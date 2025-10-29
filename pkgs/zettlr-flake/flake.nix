{
  description = "Zettlr Beta AppImage packaging flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # <-- this is the key part: define the package explicitly
    packages.${system}.zettlr-beta = pkgs.appimageTools.wrapType2 rec {
      pname = "zettlr";
      version = "4.0.0-beta.1";

      src = pkgs.fetchurl {
        url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-x86_64.AppImage";
        hash = "sha256-18dybnh1vllbs8ngzr1v8ldx0dalj3h3xbqqa9lh6m97chpd7s69";
      };

      extraPkgs = pkgs: [
        pkgs.texliveMedium
        pkgs.pandoc
      ];

      extraInstallCommands =
        let
          contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
        in ''
          install -m 444 -D ${contents}/zettlr.desktop $out/share/applications/zettlr.desktop
          install -m 444 -D ${contents}/zettlr.png $out/share/icons/hicolor/512x512/apps/zettlr.png
          substituteInPlace $out/share/applications/zettlr.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=zettlr'
        '';

      meta = with pkgs.lib; {
        description = "Markdown editor for academic writing and note-taking";
        homepage = "https://zettlr.com";
        license = licenses.gpl3Plus;
        platforms = [ "x86_64-linux" ];
        mainProgram = "zettlr";
      };
    };

    # optionally provide a defaultPackage for easier building
    defaultPackage.${system} = self.packages.${system}.zettlr-beta;
  };
}
