# Enable HTTP2 on Apache

## Prerequisits
list existion versions installed

```sh
sudo update-alternatives --list php
```

## **Must  install `php*-fpm` otherwise php config will break the site.**

First install or update to desired php version.

```sh
sudo apt-get install php8.3-fpm
```

Then enable that for apache

```sh
sudo a2enconf php8.3-fpm
sudo a2enmod proxy_fcgi
```

We can disable other versions if there is multiple version installed.

```sh
sudo a2dismod php8.3
sudo a2dismod php7.4
```

Now for HTTP2 module to be enabled we need to disable `mpm_prefork` module.

```sh
sudo a2dismod mpm_prefork  # first try
```

If there is any dependency error then we can disble that  by following. Here `php8.3` has dependency on `mpm_prefork`. With this first it disables `php8.3` then `mpm_prefork`.

```sh
sudo a2dismod php8.3 mpm_prefork # if not disabaled
```

Now Enable `mpm_event`.

```sh
sudo a2enmod mpm_event
```

Now restart the apache.

```sh
sudo systemctl restart apache2
```

## Enable HTTP/2 support in Apache

To get HTTP/2 working on Apache we need to enable and load SSL and HTTP/2 modules. To do so, we may run the following in the terminal:

```sh
sudo a2enmod ssl
sudo a2enmod http2
```

Restart to take effect of thr modules.

```sh
sudo systemctl restart apache2
```

Locate the `.conf` file that contains the Protocols definition. Depending on the installation, this is either found at `/etc/apache2/apache2.conf` or `/etc/apache2/mods-available/http2.conf`. To find the exact file, change to the root directory for Apache and search for the `Protocols` keyword with the grep command. Select the file that already contains a `Protocols` configuration. If there are no matches, choose the base `apache2.conf` file.

```sh
cd /etc/apache2
grep -r Protocols .
```

In our case `/etc/apache2/mods-available/http2.conf` is the file. Now edit the file.

```sh
    # Protocols h2 h2c http/1.1    # before
    Protocols h2 h2c               # after
```

This is the precidenci of protocols. To ensure forceful http2, we may just commentout `http/1.1`.

```sh
sudo systemctl restart apache2
```

Now check the site. If it's still showing http/1.1 then invalidate the cache from cdn.
