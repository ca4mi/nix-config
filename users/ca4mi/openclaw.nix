{ config, pkgs, ... }:

{
  programs.openclaw = {
    enable = true;

    environment = {
      TELEGRAM_BOT_TOKEN     = "/run/agenix/telegramBotToken";
      OPENCLAW_GATEWAY_TOKEN = "/run/agenix/openclawGatewayToken";
      OLLAMA_API_KEY         = "ollama-local";
      ANTHROPIC_API_KEY      = "/run/agenix/anthropicApiKey";
    };

    documents = ./documents;

    config = {
      models.providers.ollama = {
        api     = "ollama";
        apiKey  = "ollama-local";
        baseUrl = "http://127.0.0.1:11434";
        models  = [
          { id = "llama3.2:3b"; name = "llama3.2:3b"; reasoning = false; }
          { id = "mistral:7b"; name = "mistral:7b"; reasoning = false; }
        ];
      };

      models.providers.anthropic = {
        api    = "anthropic-messages";
	baseUrl = "https://api.anthropic.com";
	apiKey  = "ANTHROPIC_API_KEY";
        models = [
          { id = "claude-haiku-4-5-20251001"; name = "claude-haiku-4-5-20251001"; maxTokens = 4096; }
          { id = "claude-sonnet-4-5";         name = "claude-sonnet-4-5";         maxTokens = 4096; }
        ];
      };

      agents.defaults.model = {
        primary   = "anthropic/claude-haiku-4-5-20251001";
        fallbacks = [ "ollama/qwen2.5:7b-fast" ];
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
