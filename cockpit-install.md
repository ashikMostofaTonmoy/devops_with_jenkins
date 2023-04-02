# Cockpit installation

By default cockpit is usually shipped with rocky. Still if its not installed by default, you can use the following process.

process is taken from https://vitux.com/how-to-install-cockpit-on-rocky-linux-8/

```sh
sudo dnf update
sudo dnf install epel-release
sudo dnf install cockpit
sudo systemctl start cockpit.socket
sudo systemctl enable cockpit.socket
sudo systemctl status cockpit.socket
```

Now let’s configure the firewall as Cockpit runs on port 9090 for HTTP access. So please execute the following command for it:

```sh
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
```

Also, use the below command to reload the firewall to make changes successfully:

```sh
sudo firewall-cmd --reload
```

To check the firewall configuration, use the following command:

```sh
sudo firewall-cmd --list-all
```

As Cockpit is a web-based service, you need the IP address of the active server to access it. To check the IP address, run the following command:

```sh
ifconfig
```

Now if you're on a virtual machine create a bridge network. then access that.
