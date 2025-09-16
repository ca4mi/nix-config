{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./secrets
    ./tailscale
  ];

  time.timeZone = "Asia/Ulaanbaatar";
 
  users.users = {
    ca4mi = {
      hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
    };
    root = {
      initialHashedPassword = config.age.secrets.hashedUserPassword.path;
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      LoginGraceTime = 0;
      PermitRootLogin = "no";
    };
    hostKeys = [
      {
        path = "/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    fastfetch
    tmux
    iotop
    nmap
    jq
    inputs.agenix.packages."${system}".default
    podman
    podman-compose
    ffmpeg
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  system.stateVersion = "25.05";
}

