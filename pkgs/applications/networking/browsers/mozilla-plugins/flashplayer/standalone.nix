{ stdenv
, lib
, fetchurl
, alsaLib
, atk
, bzip2
, cairo
, curl
, expat
, fontconfig
, freetype
, gdk_pixbuf
, glib
, glibc
, graphite2
, gtk2
, harfbuzz
, libICE
, libSM
, libX11
, libXau
, libXcomposite
, libXcursor
, libXdamage
, libXdmcp
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, libXt
, libXxf86vm
, libdrm
, libffi
, libpng
, libvdpau
, libxcb
, libxshmfence
, nspr
, nss
, pango
, pcre
, pixman
, zlib
, unzip
, debug ? false
}:

let
  arch =
    if      stdenv.system == "x86_64-linux" then
      "x86_64"
    else if stdenv.system == "i686-linux"   then
      "i386"
    else throw "Flash Player is not supported on this platform";
in
stdenv.mkDerivation rec {
  name = "flashplayer-standalone-${version}";
  version = "24.0.0.221";

  src = fetchurl {
    url =
      if debug then
        "https://fpdownload.macromedia.com/pub/flashplayer/updaters/24/flash_player_sa_linux_debug.x86_64.tar.gz"
      else
        "https://fpdownload.macromedia.com/pub/flashplayer/updaters/24/flash_player_sa_linux.x86_64.tar.gz";
    sha256 =
      if debug then
        "0cy81cml72ayx2wa0fd9vgp2wzny866jasahndg01v0jfxcxw5rz"
      else
        "0xgiycd47mzmwvmhbi0ig3rd7prksfdpcd4h62as1m9gs1ax4d7l";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  dontStrip = true;
  dontPatchELF = true;

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -pv flashplayer${lib.optionalString debug "debugger"} $out/bin

    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$rpath" \
      $out/bin/flashplayer${lib.optionalString debug "debugger"}
  '';

  rpath = lib.makeLibraryPath
    [ stdenv.cc.cc
      alsaLib atk bzip2 cairo curl expat fontconfig freetype gdk_pixbuf glib
      glibc graphite2 gtk2 harfbuzz libICE libSM libX11 libXau libXcomposite
      libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama
      libXrandr libXrender libXt libXxf86vm libdrm libffi libpng libvdpau
      libxcb libxshmfence nspr nss pango pcre pixman zlib
    ];

  meta = {
    description = "Adobe Flash Player standalone executable";
    homepage = https://www.adobe.com/support/flashplayer/debug_downloads.html;
    license = stdenv.lib.licenses.unfree;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
  };
}
