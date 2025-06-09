# { pkgs, ... }:

self: super: {
  dusal-bicheech-xkb = self.stdenv.mkDerivation rec {
    name = "dusal-bicheech-xkb-layout";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/X11/xkb/symbols
      cp -a $src/mn $out/share/X11/xkb/symbols/
    '';
    src = super.pkgs.fetchFromGitHub {
      owner = "almas";
      repo = "Dusal_Bicheech_XKB";
      rev = "main"; 
      sha256 = "sha256-dzB8w97RQSv/6Qc3IH3dc1U1R+lyE83eglcibngIEMg=";
    };
  };
}
