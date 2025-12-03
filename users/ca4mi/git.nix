{
  inputs,
  lib,
  config,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "ca4mi";
      user.email = "mail@ca4mi.net";
      extraConfig = {
        core = {
          sshCommand = "ssh -o 'IdentitiesOnly=yes' -i ~/.ssh/ca4mi";
	};
      };
    };
  };
}

