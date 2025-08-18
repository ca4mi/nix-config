{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./secrets
  ];

  services.copyparty = {
    enable = true;
    settings = {
      i = "0.0.0.0";
      p = [ 3210 3211 ];
      no-reload = true;
    };

    accounts = {
      ca4mi = {
        passwordFile = config.age.secrets.copypartyUserPassword.path;
      };
    };

    volumes = {
      "/" = {
        path = "/run/media/storage";
        access = {
          r = "*";
          rw = [ "ca4mi" ];
        };
        flags = {
          fk = 4;
          scan = 60;
          e2d = true;
          d2t = true;
          nohash = "\.iso$";
        };
      };
    };

    openFilesLimit = 8192;
  };
}
