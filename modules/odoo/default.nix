{ 
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  account-reconcile = pkgs.fetchFromGitHub {
    owner = "OCA";
    repo = "account-reconcile";
    rev = "88539397011d58d9837cb2aec7142dc285d14394";
    sha256 = "sha256-X4SzbZj3LxGlB94X3RP88fo3lwuGVxsX++gK89f0cPI="; 
  };
in
{
  imports = [
  ];

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "odoo";
        ensureClauses = {
          createrole = true;
          createdb = true;
          login = true;
        };
      }
    ];
  };

  services.odoo = {
    enable = true;
    addons = [
      account-reconcile
    ];
    settings = {
      options = {
        admin_passwd = "$pbkdf2-sha512$100000$J9JiKWoaqAOk90T9m0xfWFqlFAbDBu7CfLYdveB1Nhg=$+cvbuGovwlFZyPJ1Fa32FnPZJbRf8Tl7R7zGCekbd7uCD2r9zAmaNt+x0Hhuwrv6f0ktJZSwDwreH57QEUhplw==";
        db_name = "ca4mi";
      };
    };
    autoInitExtraFlags = [ "--without-demo=all" ];
  };

  # systemctl start postgresqlBackup-odoo.service
  # cd /var/backup/postgresql/
  services.postgresqlBackup = {
    enable = true;
    databases = [ "ca4mi" ];
    compression = "none";
  };
}
