{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.flutter
    pkgs.nodejs
    pkgs.chromium
  ];
  shellHook = ''
    flutter config --enable-web
  '';
}
