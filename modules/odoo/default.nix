{ 
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
  ];

  services.odoo = {
    enable = true;
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
