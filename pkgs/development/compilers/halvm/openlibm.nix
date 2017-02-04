{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "openlibm";
  makeFlags = [ "prefix=$(out)" ];
  src = fetchFromGitHub {
     owner = "acw";
     repo = "openlibm";
     rev = "587ff290d9ee0558d30197099c6e7d27ec8f0387";
     sha256 = "01nm81bcb69spqalawbm1lcx7vs2nyw7cv8igdxh2hzymrmfby6r";
  };
}
