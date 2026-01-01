{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  };
}

