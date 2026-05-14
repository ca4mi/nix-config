{ config, pkgs, ... }:

{
  programs.openclaw = {
    enable = true;

    environmentFiles = [
      config.age.secrets.telegramBotToken.path
      config.age.secrets.openclawGatewayToken.path
    ];

    config = {
      models.providers.ollama = {
        apiKey  = "ollama-local";
        baseUrl = "http://127.0.0.1:11434";  # no /v1 — native Ollama API
        api     = "ollama";                  # required for tool calling
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
        enabled  = true;
        token    = { ref = { source = "env"; id = "TELEGRAM_BOT_TOKEN"; }; };

        dmPolicy    = "allowlist";
        allowFrom   = [ "YOUR_NUMERIC_TELEGRAM_ID" ];  # get from @userinfobot
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
