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
  networking.hostId = "8425e349";
  networking.firewall.enable = false;

  boot.zfs.forceImportRoot = true;

  # legacy boot
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/sda";
  };

  # user
  users.users.ca4mi = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "users" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6eAo8+0E5FTs0RgeZcBujZvElu1OK7kCI/EBZ0s2xi mail@ca4mi.net"
    ];
  };
}
