# Description

Containerized GLPI.

* This Container: https://github.com/coleyon/glpi-docker
* GLPI Official Site: https://glpi-project.org/
* GLPI Official Docs: https://glpi-install.readthedocs.io/en/latest/install/index.html
* GLPI Official Releases: https://github.com/glpi-project/glpi/releases


# Quick Start

**build and up the container**

    ```
    $ cp .env.example .env
    $ cp .mysql.env.example .mysql.env      # please change ID and Passwowrd
    $ docker-compose build
    Successfully built 1e8b04b73dbd
    Successfully tagged glpi-production:latest
    $ docker-compose up -d
    $ docker container ls | grep glpi
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
    450ca3617c50        glpi-production     "docker-php-entrypoi…"   7 minutes ago       Up 7 minutes        0.0.0.0:80->80/tcp, 443/tcp         glpi
    b9b87da7aa14        mysql:5.7           "docker-entrypoint.s…"   7 minutes ago       Up 7 minutes        0.0.0.0:3306->3306/tcp, 33060/tcp   mysql-glpi
    ```


**install glpi**

* You to access http://localhost and completes [installation steps](https://glpi-install.readthedocs.io/en/latest/install/index.html#installation).

    ```
    Step 1 Database connection setup            # see .mysql.env
    SQL server (MariaDB or MySQL) : mysql
    SQL user: root
    SQL password: P@ssw0rd
    ```

* And [remove installation file](https://glpi-install.readthedocs.io/en/latest/install/index.html#post-installation).

    ```
    $ docker exec -it 450ca3617c50 /bin/bash -c "rm /var/www/html/glpi/install/install.php"
    ```



# GLPI Prerequires

https://glpi-install.readthedocs.io/en/latest/prerequisites.html

# GLPI Version

* [glpi](https://github.com/glpi-project/glpi/releases)
* [mysql:5.7](https://hub.docker.com/_/mysql)


# Usage

**Apache2 Configures**

* ``containers/apache2/``

**php.ini**

* ``containers/php/conf.d/``

**GLPI Source Code**

* ``patches/``

  ```
  $ ls
  glpi_official/  glpi_original/
  $ diff -u glpi_official/inc/somecode.php glpi_original/inc/somecode.php > inc-somecode.php.patch
  ```

**How to add a plugin**

* Copy to ``/var/www/html/glpi/plugins/`` on the container instance. This directory is provided persistent disk

  ```
  $ wget https://github.com/pluginsGLPI/ocsinventoryng/releases/download/1.6.0/glpi-ocsinventoryng-1.6.0.tar.gz
  $ tar -xzf glpi-ocsinventoryng-1.6.0.tar.gz
  $ ls
  ocsinventoryng/
  $ docker cp ocsinventoryng/ glpi:/var/www/html/glpi/plugins/
  $ docker exec -it glpi chown -R www-data: /var/www/html/glpi/plugins/ocsinventoryng
  ```

**How to add l10n**

* Create po, mo file by some tools (i.e. poedit) and copy to ``/var/www/html/glpi/locales`` .

  ```
  $ docker cp ja_JP.mo glpi:/var/www/html/glpi/locales/
  $ docker cp ja_JP.po glpi:/var/www/html/glpi/locales/
  ```

**How to restoring MySQL from dump file**

* restore

  ```
  $ cp xxx.sql ./dump/
  $ docker exec -it glpi /bin/bash -c "mysql -uroot -p${PASSWD} ${DBNAME} < /tmp/xxx.sql"
  ```
