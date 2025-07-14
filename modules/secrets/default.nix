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
      admin_passwd.file = "${inputs.secrets}/admin_passwd.age";
      db_password.file = "${inputs.secrets}/db_password.age";
    };
  };
}

