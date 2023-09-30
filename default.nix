with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "gruvbox-minimal-sddm";
  buildInputs = [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.sddm
  ];
}
