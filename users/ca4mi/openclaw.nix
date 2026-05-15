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
          { id = "gemma3:4b"; name = "gemma3:4b"; reasoning = false; }
          { id = "qwen2.5:3b"; name = "qwen2.5:3b"; reasoning = false; }
        ];
      };

      agents.defaults.model = {
        primary   = "ollama/gemma3:4b";
        fallbacks = [ "ollama/qwen2.5:3b" ];
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
