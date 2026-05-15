{ config, pkgs, ... }:

{
  programs.openclaw = {
    enable = true;

    environment = {
      TELEGRAM_BOT_TOKEN     = "/run/agenix/telegramBotToken";
      OPENCLAW_GATEWAY_TOKEN = "/run/agenix/openclawGatewayToken";
      OLLAMA_API_KEY         = "ollama-local";
    };

    documents = ./documents;

    config = {
      models.providers.ollama = {
        api     = "ollama";
        apiKey  = "ollama-local";
        baseUrl = "http://127.0.0.1:11434";
        models  = [
          { id = "qwen2.5:7b"; name = "qwen2.5:7b"; reasoning = false; }
          { id = "mistral:7b"; name = "mistral:7b"; reasoning = false; }
        ];
      };

      agents.defaults.model = {
        primary   = "ollama/qwen2.5:7b";
        fallbacks = [ "ollama/mistral:7b" ];
      };

      gateway = {
        auth = {
          mode  = "token";
          token = {
            source   = "env";
            id       = "OPENCLAW_GATEWAY_TOKEN";
            provider = "openclaw";
          };
        };
      };
    };
  };
}
