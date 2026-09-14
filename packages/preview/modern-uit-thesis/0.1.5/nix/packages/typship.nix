{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "typship";
  version = "v0.4.1";
  src = fetchFromGitHub {
    owner = "sjfhsjfh";
    repo = pname;
    rev = version;
    hash = "sha256-e7jGc/ENVEMGzXl+sidzNBFy+qZo9+ClRPYhsXtnyD8=";
  };
  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
    perl
  ];
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  useFetchCargoVendor = true;
  cargoHash = "sha256-lRB+GL5dgl22B+qBZV273V9tavGu5HqK2Z9JFyqVoK8=";
}
