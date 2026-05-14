{ config, pkgs, ... }:

{
  programs.openclaw = {
    enable = true;

    # Values that are file paths get read at runtime by OpenClaw
    # So we point to the agenix-decrypted files directly — safe, no build-time read
    environment = {
      TELEGRAM_BOT_TOKEN     = "/run/agenix/telegramBotToken";
      OPENCLAW_GATEWAY_TOKEN = "/run/agenix/openclawGatewayToken";
      OLLAMA_API_KEY         = "ollama-local";
    };

    documents = ./documents;

    config = {
      models.providers.ollama = {
        apiKey  = "ollama-local";
        baseUrl = "http://127.0.0.1:11434";
        api     = "ollama";
      };

      agents.defaults.model = {
        primary   = "ollama/qwen2.5:7b";
        fallbacks = [ "ollama/mistral:7b" ];
      };

      agents.defaults.models = {
        "ollama/qwen2.5:7b" = { reasoning = false; };
        "ollama/mistral:7b" = { reasoning = false; };
      };

      channels.telegram = {
        enabled     = true;
        token       = { ref = { source = "env"; id = "TELEGRAM_BOT_TOKEN"; }; };
        dmPolicy    = "allowlist";
        allowFrom   = [ "YOUR_NUMERIC_TELEGRAM_ID" ];
        groupPolicy = "disabled";
      };

      gateway = {
        mode = "service";
        bind = "127.0.0.1:3000";
        auth.token = { ref = { source = "env"; id = "OPENCLAW_GATEWAY_TOKEN"; }; };
      };
    };
  };
}
