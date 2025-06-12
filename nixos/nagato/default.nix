{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  # hostname
  networking.hostName = "nagato";
  networking.firewall.enable = false;

  # legacy boot
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/sda";
  };
}
