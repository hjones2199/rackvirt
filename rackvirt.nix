with (import <nixpkgs> {});
derivation {
  name = "rackvirt";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  inherit racket-minimal libvirt coreutils;
  binutils = binutils-unwrapped;
  src = ./src;
  system = builtins.currentSystem;
}
