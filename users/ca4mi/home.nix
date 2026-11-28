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
    pi-coding-agent   # from nixpkgs: pinned by flake.lock, telemetry/version-check off by default
  ];

  # Pi coding agent: link ONLY static files from a local checkout of pi-config.
  #  - mkOutOfStoreSymlink => nothing is copied into /nix/store (which is
  #    world-readable), and edits apply immediately, no flake update needed.
  #  - Pi owns auth.json, settings.json, models-store.json and sessions/, so those
  #    are deliberately NOT linked.
  #  - mcp.json is not linked: Pi has no built-in MCP support (needs an extension).
  #  - Keep API keys out of these files: use "apiKey": "ENV_VAR_NAME" or
  #    "!command" in models.json.
  # Requires: git clone git@github.com:ca4mi/pi-config.git ~/Git/pi-config
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Git/pi-config/models.json";
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Git/pi-config/AGENTS.md";
  home.file.".pi/agent/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Git/pi-config/skills";

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
