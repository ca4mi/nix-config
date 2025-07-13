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
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  home = {
    username = "ca4mi";
    homeDirectory = "/home/ca4mi";
  };

  home.packages = with pkgs; [
    git-crypt
    syncthing
    kitty
    obs-studio
    mullvad-browser
    libreoffice
    tmux
  ];

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
        font_size = "16.0";
        shell = "/run/current-system/sw/bin/tmux";
      };
    };
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.05";
}
