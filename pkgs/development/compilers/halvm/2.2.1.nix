{ stdenv, fetchurl, fetchpatch, fetchgit, bootPkgs, perl, gmp, ncurses, libiconv, binutils, coreutils, autoconf
, hscolour, patchutils, xen, integer-lib ? "integer-simple", automake
}:

let
  inherit (bootPkgs) ghc;
  openlibm = import ./openlibm.nix {};
  halvm = fetchgit {
    url = "https://github.com/GaloisInc/HaLVM";
    rev = "c9451b0bfce65b0056107776d7ed3d32c6d125bf";
    sha256 = "1v5dswdqfxrr4qrsbp3sgcr4xpx5mmvr8x5qs3dbxr1pi35acj1v";
    fetchSubmodules = true;
   };
  libivc = import ./libivc.nix{};
in
stdenv.mkDerivation rec {
  version = "8.0.1";
  name = "ghc-${version}";
  src = fetchgit {
    url = "https://github.com/GaloisInc/halvm-ghc";
    rev = "822191da28533109c89e10317e5aae110611aabd";
    sha256 = "1g4qim89w8w0mbavkr138g8slgwj1dl33653zq6c7cynb9n34kwd";
    fetchSubmodules = true;
   };
  buildInputs = with bootPkgs; [ ghc perl hscolour autoconf automake happy alex ];
  enableParallelBuilding = true;
  outputs = [ "out" "doc" ];

  prePatch = ''
   # Link Xen headers
   ln -sf ${xen}/include/xen rts/xen/include/xen

   # Link HALVMCore into GHC's library path, where it will be found and built by the GHC build system.
   cp -r ${halvm}/src/HALVMCore libraries/HALVMCore
   chmod -R +w libraries/HALVMCore

   # Link XenDevice into GHC's library path, where it will be found and built by the GHC build system.
   cp -r ${halvm}/src/XenDevice libraries/XenDevice
   chmod -R +w libraries/XenDevice

   # Replace libc headers with minlibc
   cp -r rts/minlibc/include libraries/base/libc-include
   chmod -R +w libraries/base/libc-include
  '';

  buildMK = ''
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries="${gmp.out}/lib"
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes="${gmp.dev}/include"
    libraries/terminfo_CONFIGURE_OPTS    += --configure-option=--with-curses-includes="${ncurses.dev}/include"
    libraries/terminfo_CONFIGURE_OPTS    += --configure-option=--with-curses-libraries="${ncurses.out}/lib"
    DYNAMIC_BY_DEFAULT = NO
    Stage1Only  := YES
    DYNAMIC_GHC_PROGRAMS := NO
    GhcLibWays = v p
    GhcRTSWays = thr v p debug thr_debug

    SRC_HC_OPTS     = -O -H64m
    GhcStage1HcOpts = -O -fasm
    GhcStage2HcOpts = -O2 -fasm
    GhcHcOpts       = -Rghc-timing
    GhcLibHcOpts    = -O2

    SplitObjs          = YES
    HADDOCK_DOCS       = NO
    BUILD_DOCBOOK_HTML = NO
    BUILD_SPHINX_HTML  = NO
    BUILD_SPHINX_PDF   = NO
    INTEGER_LIBRARY := ${integer-lib}

    SRC_CC_OPTS += -fno-unit-at-a-time
    SRC_CC_OPTS += -fno-stack-protector
    SRC_CC_OPTS += -fomit-frame-pointer
    SRC_CC_OPTS += -fno-asynchronous-unwind-tables
    SRC_CC_OPTS += -mno-red-zone
    SRC_CC_OPTS += -fno-builtin
    SRC_CC_OPTS += -DCONFIG_X86_64
  '';

  preConfigure = ''
    echo "${buildMK}" > mk/build.mk
    ./boot
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
   '' + stdenv.lib.optionalString stdenv.isDarwin ''
     export NIX_LDFLAGS+=" -no_dtrace_dof"
   echo monkey
   ls -l libraries
   '';

  configureFlags = [
    "--with-gcc=${stdenv.cc}/bin/cc"
    "--with-gmp-includes=${gmp.dev}/include" "--with-gmp-libraries=${gmp.out}/lib"
    "--with-curses-includes=${ncurses.dev}/include" "--with-curses-libraries=${ncurses.out}/lib"
    "--datadir=$doc/share/doc/ghc"
    "--disable-large-address-space"
    "--prefix=$out"
  ] ++ stdenv.lib.optional stdenv.isDarwin [
    "--with-iconv-includes=${libiconv}/include" "--with-iconv-libraries=${libiconv}/lib"
  ];

  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" ] ++ stdenv.lib.optional (!stdenv.isDarwin) "--keep-file-symbols";

  postInstall = ''
    paxmark m $out/lib/${name}/bin/{ghc,haddock}

    # Install the bash completion file.
    install -D -m 444 utils/completion/ghc.bash $out/share/bash-completion/completions/ghc

    # Patch scripts to include "readelf" and "cat" in $PATH.
    for i in "$out/bin/"*; do
      test ! -h $i || continue
      egrep --quiet '^#!' <(head -n 1 $i) || continue
      sed -i -e '2i export PATH="$PATH:${stdenv.lib.makeBinPath [ binutils coreutils ]}"' $i
    done
  '';

  passthru = {
    inherit bootPkgs;
  };

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = with stdenv.lib.maintainers; [ marcweber andres peti ];
    inherit (ghc.meta) license platforms;
  };
}
