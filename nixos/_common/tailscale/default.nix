{
  config,
  pkgs,
  lib,
  ...
}:
{

  environment.systemPackages = [ pkgs.tailscale ];

  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  };
}

