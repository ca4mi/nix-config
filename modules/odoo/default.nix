{ 
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../secrets
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
    settings = {
      options = {
        admin_passwdFile = config.age.secrets.admin_passwd.path;
        db_user = "odoo";
        db_passwordFile = config.age.secrets.db_password.path;
      };
    };
    addons = [ ];
    autoInit = true;
    autoInitExtraFlags = [ "--without-demo=all" ];
  };

  # systemctl start postgresqlBackup-odoo.service
  # cd /var/backup/postgresql/
  services.postgresqlBackup = {
    enable = true;
    databases = [ "odoo" ];
    compression = "none";
  };
  
}
