# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  # Create the missing modules patch locally in home-manager
  hermes-missing-modules = pkgs.runCommand "hermes-missing-modules" {} ''
    mkdir -p $out
    cp -r ${inputs.hermes-agent}/hermes_state_* $out/
  '';
in
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
    sessionVariables = {
      HERMES_HOME = lib.mkForce "/var/lib/hermes/.hermes";
    };
  };

  home.packages = with pkgs; [
    git-crypt
    kitty
    tmux
    gphoto2

    # Wrapped Hermes Desktop with required environment variables
    (pkgs.symlinkJoin {
      name = "hermes-desktop-wrapped";
      paths = [ inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hermes-desktop \
          --prefix PYTHONPATH : "${hermes-missing-modules}" \
          --set HERMES_HOME "/var/lib/hermes/.hermes"
      '';
    })
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
        font_size = "12.0";
        shell = "/run/current-system/sw/bin/tmux";
      };
    };
  };

  programs.home-manager.enable = true;

  # Disabled default Hermes Desktop module to prevent duplicate/unwrapped installs
  programs.hermes-agent = {
    enable = false;
    desktop.enable = false;
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.05";
}
