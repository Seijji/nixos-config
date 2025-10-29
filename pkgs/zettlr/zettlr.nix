{ appimageTools
, lib
, fetchurl
, makeWrapper
}:

appimageTools.wrapType2 rec {
  pname = "zettlr";
  version = "4.0.0-beta.1";

  src = fetchurl {
    url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-x86_64.AppImage";
    hash = "sha256-18dybnh1vllbs8ngzr1v8ldx0dalj3h3xbqqa9lh6m97chpd7s69";
  };

  extraPkgs = pkgs: with pkgs; [
    texliveMedium
    pandoc
  ];

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      appimageContents = appimageTools.extractType2 { inherit pname version src; };
    in ''
      wrapProgram $out/bin/zettlr \
        --add-flags '--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true'
      install -Dm444 ${appimageContents}/zettlr.desktop -t $out/share/applications/
      install -Dm444 ${appimageContents}/zettlr.png -t $out/share/icons/hicolor/512x512/apps/
      substituteInPlace $out/share/applications/zettlr.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

  meta = with lib; {
    description = "Markdown editor for writing academic texts and taking notes";
    homepage = "https://www.zettlr.com";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zettlr";
  };
}
