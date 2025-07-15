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
    settings = {
      options = {
        admin_passwd = "$pbkdf2-sha512$100000$J9JiKWoaqAOk90T9m0xfWFqlFAbDBu7CfLYdveB1Nhg=$+cvbuGovwlFZyPJ1Fa32FnPZJbRf8Tl7R7zGCekbd7uCD2r9zAmaNt+x0Hhuwrv6f0ktJZSwDwreH57QEUhplw==";
        db_name = "odoo-18";
      };
    };
    autoInitExtraFlags = [ "--without-demo=all" ];
  };

  # systemctl start postgresqlBackup-odoo.service
  # cd /var/backup/postgresql/
  services.postgresqlBackup = {
    enable = true;
    databases = [ "odoo-18" ];
    compression = "none";
  };
}
