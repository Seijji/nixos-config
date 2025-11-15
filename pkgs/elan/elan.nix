# elan.nix
{ lib
, stdenv
, fetchzip
, maven
, jdk21
, makeWrapper
, unzip
}:

let
  version = "7.0";

  src = fetchzip {
    url = "https://www.mpi.nl/tools/elan/ELAN_7-0_src.zip";
    hash = "sha256-AChWZSrVbeAl2Dn0fExMU3mesAXaaXz13Us1iwd9VWc=";
    stripRoot = false;
  };

  # Fetch Maven dependencies separately
  mavenDeps = stdenv.mkDerivation {
    name = "elan-${version}-maven-deps";
    inherit src;

    nativeBuildInputs = [ maven jdk21 ];

    buildPhase = ''
      # Find the actual source directory with pom.xml
      pomDir=$(find . -name "pom.xml" -type f | head -n1 | xargs dirname)

      if [ -z "$pomDir" ]; then
        echo "ERROR: Could not find pom.xml"
        exit 1
      fi

      cd "$pomDir"

      # Actually build the project to fetch ALL dependencies (plugins + deps)
      # This is more reliable than dependency:go-offline
      mvn package -DskipTests -Dmaven.repo.local=$out/.m2/repository
    '';

    installPhase = ''
      # The .m2 directory is already at $out/.m2 from buildPhase
      echo "Maven dependencies cached at $out/.m2"
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-vHBxyDLX7EnvzdD8ZlyoYBbEl70T1scCbRStOA0Jde0=";

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
  };

in stdenv.mkDerivation {
  pname = "elan";
  inherit version src;

  nativeBuildInputs = [ maven jdk21 makeWrapper unzip ];

  buildPhase = ''
    # Find the directory with pom.xml
    pomDir=$(find . -name "pom.xml" -type f | head -n1 | xargs dirname)
    cd "$pomDir"

    # Copy Maven deps to a writable location with proper permissions
    export HOME=$TMPDIR
    mkdir -p $HOME/.m2/repository
    cp -r ${mavenDeps}/.m2/repository/* $HOME/.m2/repository/
    chmod -R +w $HOME/.m2

    # Build with local repository
    mvn package -DskipTests -Dmaven.repo.local=$HOME/.m2/repository
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/elan $out/share/applications

    # ELAN builds multiple JARs. We want the main one: elan-X.Y.jar (not elan4annex or recognizer)
    # Pattern: exact match for elan-[version].jar
    mainJar=$(find target -maxdepth 1 -name "elan-${version}.jar" -type f | head -n1)

    if [ -z "$mainJar" ]; then
      echo "Error: Could not find elan-${version}.jar in target/"
      echo "Available JARs in target/:"
      find target -maxdepth 1 -name "*.jar" -type f
      exit 1
    fi

    echo "Found main JAR: $mainJar"
    cp "$mainJar" $out/share/elan/elan.jar
    echo "Copied JAR to $out/share/elan/elan.jar"

    # Copy dependencies
    if [ -d target/lib ]; then
      cp -r target/lib $out/share/elan/
      echo "Copied lib directory"
    else
      echo "Warning: No lib directory found"
    fi

    # Check if JAR has Main-Class manifest
    echo "Checking manifest..."
    mainClass=$(unzip -p $out/share/elan/elan.jar META-INF/MANIFEST.MF 2>/dev/null | grep "Main-Class:" | cut -d' ' -f2 | tr -d '\r' || echo "")

    if [ -n "$mainClass" ]; then
      echo "Found Main-Class in manifest: $mainClass"
      # JAR has Main-Class, can use -jar
      makeWrapper ${jdk21}/bin/java $out/bin/elan \
        --add-flags "-jar $out/share/elan/elan.jar" \
        --set JAVA_HOME "${jdk21}"
    else
      echo "No Main-Class found, using classpath with mpi.eudico.client.annotator.ELAN"
      # No Main-Class, use classpath
      makeWrapper ${jdk21}/bin/java $out/bin/elan \
        --add-flags "-cp $out/share/elan/elan.jar:$out/share/elan/lib/*" \
        --add-flags "mpi.eudico.client.annotator.ELAN" \
        --set JAVA_HOME "${jdk21}"
    fi

    echo "Created wrapper at $out/bin/elan"

    # Create desktop entry for applications menu
    cat > $out/share/applications/elan.desktop <<EOF
[Desktop Entry]
Type=Application
Name=ELAN
Comment=Linguistic annotation tool for audio and video
Exec=$out/bin/elan
Icon=elan
Categories=AudioVideo;Education;Science;
Terminal=false
EOF

    echo "Created desktop entry"
  '';

  meta = with lib; {
    description = "ELAN linguistic annotator - annotation tool for audio and video recordings";
    homepage = "https://www.mpi.nl/tools/elan";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
