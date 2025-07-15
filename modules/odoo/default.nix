{ 
  inputs,
  config,
  lib,
  ...
}:
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
    addons = [ ];
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
