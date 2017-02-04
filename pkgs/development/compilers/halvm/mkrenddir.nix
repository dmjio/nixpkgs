{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
   name = "mkrenddir";
   src = fetchFromGitHub {
     owner = "GaloisInc";
     repo = "HaLVM";
     rev = "d10d5ac94332c48f1f824261dcf29803b001640e";
     sha256 = "09j81pwff400ylmiv1w3q8q8qwk8frx1x52vma9cfjj5lvb2jw0i";
   };
   buildCommand = ''
     mkdir -p $out/bin
     ${gcc}/bin/gcc -I${xen}/include -o mkrenddir.o -c $src/src/mkrenddir/mkrenddir.c
     ${gcc}/bin/gcc -I${xen}/include -L${xen}/lib -o $out/bin/mkrenddir mkrenddir.o -lxenstore
   '';
}
