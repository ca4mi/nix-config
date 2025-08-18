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
      copypartyUserPassword = {
        file = "${inputs.secrets}/copypartyUserPassword.age";
	owner = "copyparty";
        group = "copyparty";
	mode = "0440";
      };
    };
  };
}
