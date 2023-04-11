```sh
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.original

sudo systemctl enable --now haproxy
sudo systemctl status haproxy


sudo vi /etc/haproxy/haproxy.cfg


sudo cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.oriiginal
sudo vi /etc/keepalived/keepalived.conf

sudo systemctl restart keepalived
sudo systemctl enable --now keepalived
sudo systemctl status keepalived
```

Haproxy config

```sh
global

    log /dev/log  local0 warning
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

   stats socket /var/lib/haproxy/stats

defaults
  log global
  option  httplog
  option  dontlognull
        timeout connect 5000
        timeout client 50000
        timeout server 50000



frontend kube-apiserver
  bind *:6443
  mode tcp
  option tcplog
  default_backend kube-apiserver


backend kube-apiserver
    mode tcp
    option tcplog
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-apiserver-1 192.168.1.102:6443 check # Replace the IP address with your own.
    server kube-apiserver-2 192.168.1.104:6443 check # Replace the IP address with your own.
```

haproxy error solve on centos7

```sh
sudo setsebool haproxy_connect_any 1
```

keepalived config

```sh
global_defs {
  notification_email {
  }

  router_id LVS_DEVEL
  vrrp_skip_check_adv_addr
  vrrp_garp_interval 0
  vrrp_gna_interval 0

}



vrrp_script chk_haproxy {
  script "killall -0 haproxy"
  interval 2
  weight 2
}



vrrp_instance haproxy-vip {

  state BACKUP
  priority 100
  interface eth1                       # Network card
  virtual_router_id 60
  advert_int 1

  authentication {
    auth_type PASS
    auth_pass 1111
  }

  unicast_src_ip 192.168.1.109      # The IP address of this machine

  unicast_peer {
    192.168.1.108                         # The IP address of peer machines
  }

  virtual_ipaddress {
    192.168.1.221/24                  # The VIP address
  }

  track_script {
    chk_haproxy
  }
}
```
