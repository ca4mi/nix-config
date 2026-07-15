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
  hermesPython = pkgs.python312.withPackages (ps: [
    ps.anthropic
    ps.python-telegram-bot
  ]);
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
  ];

  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

# Ollama with CUDA
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    # loadModels = ["gemma4:12b-qat"];
    loadModels = ["justingtzk/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL_128K"];
    environmentVariables = {
      OLLAMA_NUM_CTX = "8192";
    };
  };

  systemd.services.hermes-provider-secrets = {
    description = "Inject Unsloth Studio credential into Hermes custom_providers config";
    before = [ "hermes-agent.service" ];
    requiredBy = [ "hermes-agent.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "ca4mi";
    };
    script = ''
      set -a
      . ${config.age.secrets.unslothStudioApiKey.path}
      set +a
      ${pkgs.yq-go}/bin/yq -i '
        .custom_providers = [{
          "name": "unsloth-studio",
          "base_url": "http://127.0.0.1:8000/v1",
          "api_key": strenv(OPENAI_API_KEY),
          "model": "unsloth/Qwen3-4B-Instruct-2507-GGUF"
        }]
      ' /var/lib/hermes/.hermes/config.yaml
    '';
  };

  # Hermes Agent Configuration
  services.hermes-agent = {
    enable = true;
    package = inputs.hermes-agent.packages.${pkgs.system}.default;
    addToSystemPackages = true;
    user = "ca4mi";
    group = "users";
    createUser = false;
    settings = {
      # local
      model.default = "unsloth/Qwen3-4B-Instruct-2507-GGUF";
      # model.provider = "custom";
      model.provider = "custom:unsloth-studio";
      model.max_context_tokens = 32768;
#      agent.disabled_toolsets = [
#        "vision"
#        "image_gen"
#        "tts"
#        "computer_use"
#        "web"
#      ];
#      skills.platform_disabled.telegram = [
#        "computer-use" "design-taste-frontend" "dogfood" "minimalist-ui" "online-browser"
#        "yuanbao" "ai-coding-agents" "hermes-agent" "architecture-diagram" "ascii-art"
#        "ascii-video" "baoyu-infographic" "claude-design" "comfyui" "design-md"
#        "excalidraw" "humanizer" "manim-video" "p5js" "popular-web-designs"
#        "pretext" "sketch" "songwriting-and-ai-music" "touchdesigner-mcp" "jupyter-live-kernel"
#        "himalaya" "github-auth" "github-code-review" "github-issues" "github-pr-workflow"
#        "github-repo-management" "gif-search" "heartmula" "jellyfin-media-org" "songsee"
#        "youtube-content" "audiocraft-audio-generation" "evaluating-llms-harness" "huggingface-hub" "llama-cpp"
#        "obliteratus" "ollama-local-models" "segment-anything-model" "serving-llms-vllm" "weights-and-biases"
#        "airtable" "google-workspace" "nano-pdf" "notion" "ocr-and-documents"
#        "pdf-to-markdown" "powerpoint" "teams-meeting-pipeline" "godmode" "arxiv"
#        "blogwatcher" "llm-wiki" "polymarket" "research-paper-writing" "openhue"
#        "xurl" "cloakbrowser-scraping" "environment-troubleshooting" "hermes-agent-skill-authoring" "plan"
#        "requesting-code-review" "simplify-code" "spike" "systematic-debugging" "test-driven-development"
#      ];
      # model.base_url = "http://127.0.0.1:8000/v1";
      # model.default = "justingtzk/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL_128K";
      # model.provider = "custom";
      # model.base_url = "http://127.0.0.1:11434/v1";
      # model.temperature = 1.0;
      # model.top_p = 0.95;
      # model.top_k = 64;
      # model.reasoning_effort = "low";
      # display.show_reasoning = true;
      # deepseek
      # model.default = "deepseek-v4-flash";
      # model.provider = "deepseek";
      # model.base_url = "https://api.deepseek.com";
      # anthropic
      # model.default = "claude-haiku-4-5-20251001";
      # model.provider = "anthropic";
      # model.base_url = "";
      # model.max_context_tokens = 200000;
    };
    environmentFiles = [
      # config.age.secrets.anthropicApiKey.path
      # config.age.secrets.deepseekApiKey.path
      # config.age.secrets.openrouterApiKey.path
      config.age.secrets.telegramBotToken.path
      config.age.secrets.telegramAllowedChats.path
      config.age.secrets.unslothStudioApiKey.path
    ];
  };

  systemd.services.hermes-agent.environment.PYTHONPATH =
    "${hermesPython}/lib/python3.12/site-packages";

  hardware.uinput.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.unsloth-studio = {
    image = "unsloth/unsloth";
    autoStart = true;
    ports = [
      "127.0.0.1:8000:8000"
    ];
    volumes = [
      "/var/lib/unsloth-studio/work:/workspace/work"
      "/var/lib/unsloth-studio/cache:/workspace/.cache"
      "/var/lib/unsloth-studio/studio:/workspace/studio"
    ];
    environmentFiles = [
      config.age.secrets.unslothStudioEnv.path
    ];
    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/unsloth-studio 0770 1001 102 -"
    "d /var/lib/unsloth-studio/work 0770 1001 102 -"
    "d /var/lib/unsloth-studio/cache 0770 1001 102 -"
    "d /var/lib/unsloth-studio/studio 0770 1001 102 -"
  ];

  systemd.services.unsloth-studio-autoload.script = ''
    set -a
    . ${config.age.secrets.unslothStudioApiKey.path}
    set +a
    ${pkgs.yq-go}/bin/yq '
      .custom_providers = [{
        "name": "unsloth-studio",
        "base_url": "http://127.0.0.1:8000/v1",
        "api_key": strenv(OPENAI_API_KEY),
        "model": "unsloth/Qwen3-4B-Instruct-2507-GGUF"
      }]
    ' /var/lib/hermes/.hermes/config.yaml > /var/lib/hermes/.hermes/config.yaml.tmp
    mv /var/lib/hermes/.hermes/config.yaml.tmp /var/lib/hermes/.hermes/config.yaml

    for i in $(seq 1 60); do
      if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:8000/api/health >/dev/null 2>&1; then
        break
      fi
      sleep 5
    done

    for i in $(seq 1 10); do
      RESPONSE=$(${pkgs.curl}/bin/curl -sf -X POST http://127.0.0.1:8000/v1/load \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "model_path": "unsloth/Qwen3-4B-Instruct-2507-GGUF",
          "gguf_variant": "IQ4_XS",
          "max_seq_length": 32768,
	  "cache_type_kv": "q8_0"
        }' 2>&1) && break
      echo "Load attempt $i failed, retrying in 5s: $RESPONSE"
      sleep 5
    done
  '';

  systemd.services.hermes-agent = {
    after = [ "unsloth-studio-autoload.service" ];
    requires = [ "unsloth-studio-autoload.service" ];
  };

  systemd.services.unsloth-model-healthcheck = {
    description = "Ensure Unsloth Studio has a model loaded";
    serviceConfig = { Type = "oneshot"; User = "ca4mi"; };
    script = ''
      set -a
      . ${config.age.secrets.unslothStudioApiKey.path}
      set +a
      LOADED=$(${pkgs.curl}/bin/curl -sf http://127.0.0.1:8000/v1/models \
        -H "Authorization: Bearer $OPENAI_API_KEY" | ${pkgs.jq}/bin/jq -r '.data | length')
      if [ "$LOADED" = "0" ] || [ -z "$LOADED" ]; then
        ${pkgs.curl}/bin/curl -X POST http://127.0.0.1:8000/v1/load \
          -H "Authorization: Bearer $OPENAI_API_KEY" \
          -H "Content-Type: application/json" \
          -d '{"model_path": "unsloth/Qwen3-4B-Instruct-2507-GGUF", "gguf_variant": "IQ4_XS", "max_seq_length": 32768, "cache_type_kv": "q8_0"}'
      fi
    '';
  };

  systemd.timers.unsloth-model-healthcheck = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnBootSec = "2m"; OnUnitActiveSec = "2m"; };
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
