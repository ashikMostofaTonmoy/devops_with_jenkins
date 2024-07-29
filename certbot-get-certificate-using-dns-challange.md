install certbot

```sh
sudo apt-get remove certbot # remove existing / faulty certbot if installed

# perform clean certbot installation.
sudo snap install --classic certbot
```

Now this is an important part. we need to install acertbot plugin to communicate with dns. in our case it's `route53`. so we are installing the [certbot-dns-route53](https://certbot-dns-route53.readthedocs.io/en/stable/) plugin. If other plugins are needed, follow this [documentation](https://eff-certbot.readthedocs.io/en/latest/using.html#dns-plugins).

```sh
sudo snap install certbot-dns-route53
```

If get the folowing error, it means you need to give snap necessary permissions.

```sh
error: cannot perform the following tasks:
- Run hook prepare-plug-plugin of snap "certbot" (run hook "prepare-plug-plugin": 
-----
Only connect this interface if you trust the plugin author to have root on the system.
Run `snap set certbot trust-plugin-with-root=ok` to acknowledge this and then run this command again to perform the connection.
If that doesn't work, you may need to remove all certbot-dns-* plugins from the system, then try installing the certbot snap again.
-----)
```

Then first use

```sh
snap set certbot trust-plugin-with-root=ok
```

After that re-run the following command again.

```sh
sudo snap install certbot-dns-route53
```

to get staging / test certificates. replace `-d ecostays.io` with your desired domain

```sh
sudo certbot --dns-route53 \
  --verbose \
  --non-interactive \
  --agree-tos \
  -m rajib.b@w3engineers.com \
  -d ecostays.io \
  -i nginx \
  --expand \
  --test-cert
```

To delete certificate.

```sh
sudo certbot delete --cert-name ecostays.io
```

For production certificate. replace `-d ecostays.io` with your desired domain

```sh
sudo certbot --dns-route53 \
  --verbose \
  --non-interactive \
  --agree-tos \
  -m rajib.b@w3engineers.com \
  -d ecostays.io \
  -i nginx \
  --expand

```

> This certificate acquisition process can be implemented with `wildcard` also.

```sh
sudo certbot --dns-route53 \
  --verbose \
  --non-interactive \
  --agree-tos \
  -m rajib.b@w3engineers.com \
  -d "*.beta.123presto.com" \
  -i nginx \
  --expand
```
