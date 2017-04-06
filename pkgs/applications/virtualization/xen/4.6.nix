{ callPackage, fetchurl, fetchpatch, fetchgit, ... } @ args:

let
  xenConfig = rec {
    version = "4.6.5";
    xsaPatch = { name , sha256 }: (fetchpatch {
      url = "https://xenbits.xen.org/xsa/xsa${name}.patch";
      inherit sha256;
    });
    name = "xen-${version}";
    src = fetchurl {
      url = "http://bits.xensource.com/oss-xen/release/${version}/${name}.tar.gz";
      sha256 = "0mpdxy3ibrm6y9a1pa5id0c7hw5hbbpqs5m1mcbfqwbaxc08vdh8";
    };
    firmwareGits =
      [
        { git = { name = "seabios";
                  url = https://xenbits.xen.org/git-http/seabios.git;
                  rev = "rel-1.7.5";
                  sha256 = "0jk54ybhmw97pzyhpm6jr2x99f702kbn0ipxv5qxcbynflgdazyb";
                };
          patches = [ ./0000-qemu-seabios-enable-ATA_DMA.patch ];
        }
      ];
    toolsGits =
      [
        { git = { name = "qemu-xen";
                  url = https://xenbits.xen.org/git-http/qemu-xen.git;
                  rev = "refs/tags/qemu-xen-${version}";
                  sha256 = "014s755slmsc7xzy7qhk9i3kbjr2grxb5yznjp71dl6xxfvnday2";
                };
          patches = [
            (xsaPatch {
              name = "197-4.5-qemuu";
              sha256 = "09gp980qdlfpfmxy0nk7ncyaa024jnrpzx9gpq2kah21xygy5myx";
            })
            (xsaPatch {
              name = "208-qemuu-4.7";
              sha256 = "0z9b1whr8rp2riwq7wndzcnd7vw1ckwx0vbk098k2pcflrzppgrb";
            })
            (xsaPatch {
              name = "209-qemuu";
              sha256 = "05df4165by6pzxrnizkw86n2f77k9i1g4fqqpws81ycb9ng4jzin";
            })
          ];
        }
        { git = { name = "qemu-xen-traditional";
                  url = https://xenbits.xen.org/git-http/qemu-xen-traditional.git;
                  rev = "refs/tags/xen-${version}";
                  sha256 = "0n0ycxlf1wgdjkdl8l2w1i0zzssk55dfv67x8i6b2ima01r0k93r";
                };
          patches = [
            (xsaPatch {
              name = "197-4.5-qemut";
              sha256 = "17l7npw00gyhqzzaqamwm9cawfvzm90zh6jjyy95dmqbh7smvy79";
            })
            (xsaPatch {
              name = "199-trad";
              sha256 = "0dfw6ciycw9a9s97sbnilnzhipnzmdm9f7xcfngdjfic8cqdcv42";
            })
            (xsaPatch {
              name = "208-qemut";
              sha256 = "0960vhchixp60j9h2lawgbgzf6mpcdk440kblk25a37bd6172l54";
            })
            (xsaPatch {
              name = "209-qemut";
              sha256 = "1hq8ghfzw6c47pb5vf9ngxwgs8slhbbw6cq7gk0nam44rwvz743r";
            })
          ];
        }
        { git = { name = "xen-libhvm";
                  url = https://github.com/ts468/xen-libhvm;
                  rev = "442dcc4f6f4e374a51e4613532468bd6b48bdf63";
                  sha256 = "9ba97c39a00a54c154785716aa06691d312c99be498ebbc00dc3769968178ba8";
                };
          description = ''
            Helper library for reading ACPI and SMBIOS firmware values
            from the host system for use with the HVM guest firmware
            pass-through feature in Xen.
            '';
        }
      ];
  };

in callPackage ./generic.nix (args // { xenConfig=xenConfig; })
