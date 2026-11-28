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
    ];
  };

  home = {
    username = "ca4mi";
    homeDirectory = "/home/ca4mi";
  };

  home.packages = with pkgs; [
    git-crypt
    kitty
    tmux
    gphoto2
    nodejs-22_x
  ];

  # Pi coding agent: public config + private overlay
  home.file.".pi/agent".source = ./pi;
  home.file.".pi/agent/models.json".source = "${inputs.pi-config}/models.json";
  home.file.".pi/agent/mcp.json".source = "${inputs.pi-config}/mcp.json";

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      enable = true;
      sensibleOnTop = false;
      extraConfig = ''
        set-option -g default-shell ${pkgs.zsh}/bin/zsh
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "phoenix-night";
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "muse";
      };
    };

    kitty = {
      enable = true;
      themeFile = "snazzy";
      shellIntegration = {
        enableZshIntegration = true;
      };
      settings = {
        window_padding_width = 0;
        window_margin_width = 0;
        adjust_line_height = "120%";
        font_size = "12.0";
        shell = "/run/current-system/sw/bin/tmux";
      };
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.05";
}
