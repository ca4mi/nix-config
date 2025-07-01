# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  home = {
    username = "ca4mi";
    homeDirectory = "/home/ca4mi";
  };

  home.packages = with pkgs; [
    git-crypt
    btop
    syncthing
    tmux
    kitty
    fastfetch
    anydesk
    vlc
    darktable
    obs-studio
    mullvad-vpn
    mullvad-browser
    discord
    libreoffice
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
