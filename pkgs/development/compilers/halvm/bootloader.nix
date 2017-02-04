{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "halvm-bootloader";
  src = pkgs.fetchFromGitHub {
     owner = "GaloisInc";
     repo = "HaLVM";
     rev = "d10d5ac94332c48f1f824261dcf29803b001640e";
     sha256 = "09j81pwff400ylmiv1w3q8q8qwk8frx1x52vma9cfjj5lvb2jw0i";
   };
   arch =
     if pkgs.stdenv.isx86_64
       then "x86_64"
       else "i386";
   # DMJ: Not sure what I do for $(ASFLAGS) ......
   buildCommand = ''
     mkdir -p $out
     ${pkgs.gcc}/bin/gcc -o $out/start.o -I${pkgs.xen}/include -I$src/src/bootloader -c $src/src/bootloader/start.$arch.S
   '';
}

