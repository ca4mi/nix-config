{
  inputs,
  lib,
  config,
  ...
}:
{

  programs.git = {
    enable = true;
    userName = "ca4mi";
    userEmail = "mail@ca4mi.net";

    extraConfig = {
      core = {
        sshCommand = "ssh -o 'IdentitiesOnly=yes' -i ~/.ssh/ca4mi";
      };
    };
  };
}

