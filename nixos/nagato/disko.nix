{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/ata-ST9160412AS_5VG56VWT";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };

          ESP = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          nix = {
            size = "80G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };

          home = {
            size = "20G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };

          etc_nixos = {
            size = "1G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/etc/nixos";
            };
          };

          persist = {
            size = "5G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };

    nodev."/tmp" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=1777"
      ];
    };
  };
}
