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
    ./filesystems.nix
  ];

  # hostname
  networking.hostName = "nagato";
  networking.hostId = "8425e349"
  networking.firewall.enable = false;

  boot.zfs.forceImportRoot = true;

  # legacy boot
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/sda";
  };
}
