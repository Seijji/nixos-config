# zettlr-deb.nix
{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, electron
, autoPatchelfHook
, gtk3
, glib
, nss
, nspr
, alsa-lib
, cups
, dbus
, expat
, libdrm
, mesa
, xorg
, texliveFull
, pandoc
, zstd
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "zettlr";
  version = "4.0.0-beta.2";

  src = fetchurl {
    url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-amd64.deb";
    # You'll need to get this hash
    hash = "sha256-58caeMpjdOVJXvAv7CWObAIdP1G6o1ZJPwA3XoDzLts=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    pkgs.zstd
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    gtk3
    glib
    nss
    nspr
    alsa-lib
    cups
    dbus
    expat
    libdrm
    mesa
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  unpackPhase = ''
    ar x $src
    tar --use-compress-program=zstd -xf data.tar.zst
    rm -f ./usr/lib/zettlr/chrome-sandbox
  '';



  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    # ensure binary is executable
    chmod +x $out/lib/zettlr/Zettlr

    # only create symlink if not already provided
    if [ ! -e $out/bin/zettlr ]; then
      ln -s $out/lib/zettlr/Zettlr $out/bin/zettlr
    fi

    wrapProgram $out/bin/zettlr \
      --prefix PATH : ${lib.makeBinPath [ pkgs.electron pkgs.xdg-utils pkgs.zenity pkgs.coreutils pkgs.glib ]}

    runHook postInstall
  '';


  meta = with lib; {
    description = "Markdown editor for writing academic texts and taking notes";
    homepage = "https://www.zettlr.com/";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zettlr";
  };
}
