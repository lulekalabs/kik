# Welcome to Kik

Kik is all about advocates and clients. This readme tells you how to get started.


## Setup MySQL

```
mysqladmin -u root -p create kik_development
mysqladmin -u root -p create kik_test
mysqladmin -u root -p create kik_production
mysqladmin -u root -p create kik_staging

mysql -u root -p
```

``` SQL
GRANT ALL ON kik_development.* TO 'rails'@'localhost' IDENTIFIED BY 'password';
GRANT FILE ON *.* TO 'rails'@'localhost' IDENTIFIED BY 'password'; 
FLUSH PRIVILEGES; 

ALTER DATABASE `kik_development` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER DATABASE `kik_test` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER DATABASE `kik_production` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER DATABASE `kik_staging` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```

## SQL dumps

    mysqldump -u root kik_development > dump.sql

and importing

    mysql -u root kik_development < dump.sql 


## Install gem dependencies

rake gems:install


## Create Schema and seed database
rake db:migrate
rake db:seed


## Add admin user

    rake admin:user:create

Go to http://localhost:3000/admin

