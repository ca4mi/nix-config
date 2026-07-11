{
  inputs,
  lib,
  outputs,
  config,
  pkgs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  imports =
    [
      ./hardware.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "asahina";
  networking.hostId = "8425e349"; 
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # enable flatpak
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    extraLayouts = {
      mongolianqwerty = {
        description = "Mongolian QWERTY";
        languages = [ "mn" ];
        symbolsFile = "${pkgs.dusal-bicheech-xkb}/share/X11/xkb/symbols/mn";
      };
    };
  };

  # Nvidia
  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
    ];
  };


  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # prime 
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # for MTP/PTP devices
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvtopPackages.nvidia
    python313Packages.anthropic
  ];

  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

# Ollama with CUDA
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    loadModels = ["gemma4:12b-qat"];
    # loadModels = ["justingtzk/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL_128K"];
    environmentVariables = {
      # OLLAMA_NUM_CTX = "8192"; # Bumped this for the agent's memory
    };
  };

  # Hermes Agent Configuration
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    user = "ca4mi";
    group = "users";
    createUser = false;
    settings = {
      # model.default = "justingtzk/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL_128K";
      # model.provider = "custom";
      # model.base_url = "http://127.0.0.1:11434/v1";
      # model.temperature = 1.0;
      # model.top_p = 0.95;
      # model.top_k = 64;
      # deepseek
      # model.default = "deepseek-v4-flash";
      # model.provider = "deepseek";
      # model.base_url = "https://api.deepseek.com";
      # anthropic
      model.default = "claude-haiku-4-5-20251001";
      model.provider = "anthropic";
      model.base_url = "https://openrouter.ai/api/v1";
      model.reasoning_effort = "high";
      display.show_reasoning = true;
    };
    environmentFiles = [
      config.age.secrets.anthropicApiKey.path
      config.age.secrets.deepseekApiKey.path
      config.age.secrets.openrouterApiKey.path
      config.age.secrets.telegramBotToken.path
      config.age.secrets.telegramAllowedChats.path
    ];
  };

  systemd.user.services.hermes-gateway = {
    environment = {
      PYTHONPATH = "${pkgs.python312Packages.python-telegram-bot}/lib/python3.12/site-packages";
    };
  };

  hardware.uinput.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # usb 'users' group access to USB device for VM
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="usb", ATTR{idVendor}=="346d", ATTR{idProduct}=="5678", GROUP="users", MODE="0660"
  # '';

  users.users.ca4mi = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "users" "uinput" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6eAo8+0E5FTs0RgeZcBujZvElu1OK7kCI/EBZ0s2xi mail@ca4mi.net"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kalk
      kdePackages.dragon
      kdePackages.kdenlive
      xfsprogs
      freerdp
      burpsuite
      anydesk
      mediawriter
      mullvad-browser
      signal-desktop
      pkgs-unstable.davinci-resolve
      # davinci-resolve
      wineWow64Packages.stable
      # lutris
      vlc
      totem
      darktable
      obs-studio
      mediainfo
      handbrake
      libreoffice
      syncthing
      cinny-desktop
      pcsx2
    ];
  };

  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # podman
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8096
    11434
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}
