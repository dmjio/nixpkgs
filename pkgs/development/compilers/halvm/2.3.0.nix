{ stdenv, fetchgit, bootPkgs, perl, gmp, ncurses, libiconv, binutils, coreutils, autoconf
, hscolour, patchutils, xen, integer-lib ? "integer-simple", automake, gcc, git, zlib, libtool
}:

stdenv.mkDerivation rec {
  version = "2.3.0";
  name = "HaLVM-${version}";
  isHaLVM = true;
  src = fetchgit {
    rev = "e4a85cdf1f5fdc41bfedb244fe5a53b49e2a7f30";
    url = "https://github.com/GaloisInc/HaLVM";
    sha256 = "1h0vcs0wfkss2jsrr331gprfg7wfvydkxz0fgbn7g20l919bjck1";
  };
  prePatch = ''
    # Removes RPM packaging
    sed -i '311,448 d' Makefile
    sed -i '67 d' src/scripts/ldkernel.in
    sed -i '67iLDCMD="${binutils}/bin/ld $\{LINKER_SCRIPT\} -nostdlib $\{START_FILE\} $ARGS $LIBS $\{GMP_FILE\} $\{LIBM_FILE\}"' src/scripts/ldkernel.in
  '';
  buildInputs =
   let haskellPkgs =
     with bootPkgs; [
       alex happy hscolour cabal-install haddock hsc2hs
    ]; in [ gcc bootPkgs.ghc
            automake perl git binutils
            autoconf xen zlib ncurses.dev
            libtool gmp ] ++ haskellPkgs;
  preConfigure = ''
    autoconf
    patchShebangs .
  '';

  passthru = {
    inherit bootPkgs;
  };

  meta = {
    homepage = "http://github.com/GaloisInc/HaLVM";
    description = "The Haskell Lightweight Virtual Machine (HaLVM): GHC running on Xen";
    maintainers = with stdenv.lib.maintainers; [ dmj ];
    inherit (bootPkgs.ghc.meta) license platforms;
  };
}
