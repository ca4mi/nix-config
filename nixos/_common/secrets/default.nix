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
    };
  };
}

