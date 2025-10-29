final: prev: {
  zettlr =
    let
      pname = "zettlr";
      version = "4.0.0-beta.1";
      src = prev.fetchurl {
        url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-x86_64.AppImage";
        sha256 = "18dybnh1vllbs8ngzr1v8ldx0dalj3h3xbqqa9lh6m97chpd7s69";
      };
      appimageContents = prev.appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    prev.appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        # Install desktop file
        install -m 444 -D ${appimageContents}/Zettlr.desktop $out/share/applications/zettlr.desktop
        substituteInPlace $out/share/applications/zettlr.desktop \
          --replace 'Exec=AppRun --no-sandbox' 'Exec=${pname}'

        # Install icons at multiple sizes
        for size in 16 24 32 48 64 96 128 256 512 1024; do
          if [ -f "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/Zettlr.png" ]; then
            install -m 444 -D \
              ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/Zettlr.png \
              $out/share/icons/hicolor/''${size}x''${size}/apps/zettlr.png
          fi
        done
      '';
      extraPkgs = pkgs: with pkgs; [
        texliveFull
        pandoc
      ];
      extraWrapArgs = [
        "--prefix" "LD_LIBRARY_PATH" ":" "$out/usr/lib"
        "--add-flags" "--no-sandbox"
        "--add-flags" "\${NIXOS_OZONE_WL:+\${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
      ];
      meta = with prev.lib; {
        description = "Markdown editor for writing academic texts and taking notes";
        homepage = "https://www.zettlr.com/";
        license = licenses.gpl3Plus;
        platforms = [ "x86_64-linux" ];
        maintainers = [ maintainers.tfmoraes ];
        mainProgram = "zettlr";
      };
    };
}
