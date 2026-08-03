# GreyGoose Network

-------------------

Ajouter ces lignes dans /etc/network/interfaces afind 'ajouter l'addresse ip du reseau greygoose
<<<
     up ip addr add 192.168.0.1/24 dev enp0s31f6
    down ip addr del 192.168.0.1/24 dev enp0s31f6
>>>

Pour creer le reseau greygoose

docker network create \
    --driver macvlan \
    --opt macvlan_mode=bridge \
    --opt parent=enp0s31f6 \
    --internal \
    --subnet 192.168.0.0/24 \
    --ip-range 192.168.0.0/25 \
    --aux-address 192.168.0.1 \
    --aux-address 192.168.0.128 \
    greygoose

x-sklad-hosts: &sklad-hosts
  qb: 192.168.0.2
  radarr: 192.168.0.3
  sonarr: 192.178.0.4
  jackett: 192.168.0.5
  seerr: 192.168.0.6
  appdaemon: 192.168.1.7
  nodered: 192.168.0.8
