{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  networking.firewall = {
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  services.tailscale = {
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.tailscale;
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  };
}

