{
  inputs,
  ...
}:
{
  age = {
    identityPaths = [
      "/ssh/ssh_host_ed25519_key"
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

      openrouterApiKey = {
      	file  = "${inputs.secrets}/openrouterApiKey.age";
	owner = "ca4mi";
	mode  = "0400";
      };

     telegramAllowedChats = {
       file  = "${inputs.secrets}/telegramAllowedChats.age";
       owner = "ca4mi";
       mode  = "0400";
       };

     deepseekApiKey = {
       file = "${inputs.secrets}/deepseekApiKey.age";
       owner = "ca4mi";
       mode = "0400";
       };

    };
  };
}

