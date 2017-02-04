{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
   name = "convert-profile";
   src = fetchFromGitHub {
     owner = "GaloisInc";
     repo = "HaLVM";
     rev = "d10d5ac94332c48f1f824261dcf29803b001640e";
     sha256 = "09j81pwff400ylmiv1w3q8q8qwk8frx1x52vma9cfjj5lvb2jw0i";
   };
   buildCommand = ''
     ${gcc}/bin/gcc -O2 $src/src/profiling/convert-profile.c -o $out
   '';
}
