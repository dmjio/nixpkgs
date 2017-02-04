{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "LibIVC";
  src = pkgs.fetchFromGitHub {
     owner = "GaloisInc";
     repo = "HaLVM";
     rev = "d10d5ac94332c48f1f824261dcf29803b001640e";
     sha256 = "09j81pwff400ylmiv1w3q8q8qwk8frx1x52vma9cfjj5lvb2jw0i";
   };
   #DMJ: CFLAGS?
   dontInstall = true;
   buildPhase = ''
     mkdir -p $out
     gcc -o $out/libIVC.o -Isrc/libIVC -I${pkgs.xen}/include -c src/libIVC/libIVC.c
     ar rcs $out/libIVC.a $out/libIVC.o
     cp $src/src/libIVC/libIVC.h $out
   '';
}
