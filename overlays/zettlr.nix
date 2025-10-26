final: prev: {
  zettlr =
    let
      pname = "zettlr";
      version = "3.6.0";
      src = prev.fetchurl {
        url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-x86_64.AppImage";
        sha256 = "1f0iw61agiblmpzw0113mhc6mxnvynd0ac0nkxlvm5w41w52f6hq";
      };
      appimageContents = prev.appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    prev.appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/Zettlr.desktop $out/share/applications/zettlr.desktop
        install -m 444 -D ${appimageContents}/Zettlr.png $out/share/icons/hicolor/512x512/apps/zettlr.png
        substituteInPlace $out/share/applications/zettlr.desktop \
          --replace 'Exec=AppRun' 'Exec=${pname}'
      '';

      extraPkgs = pkgs: with pkgs; [ ];

      meta = with prev.lib; {
        description = "A markdown editor for the 21st century.";
        homepage = "https://www.zettlr.com/";
        license = licenses.gpl3Plus;
        platforms = [ "x86_64-linux" ];
      };
    };
}
