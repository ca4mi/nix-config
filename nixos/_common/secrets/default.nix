{
  inputs,
  ...
}:
{
  age = {
    identityPaths = [
      "/home/ca4mi/.ssh/ca4mi"
    ];
    secrets = {
      hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
      tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";

      telegramBotToken = {
        file  = "${inputs.secrets}/telegramBotToken.age";
        owner = "ca4mi";
        mode  = "0400";
      };

      openclawGatewayToken = {
        file  = "${inputs.secrets}/openclawGatewayToken.age";
        owner = "ca4mi";
        mode  = "0400";
      };

    };
  };
}

