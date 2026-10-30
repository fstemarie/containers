# GreyGoose Network

-------------------

Ajouter ces lignes dans /etc/network/interfaces afin d 'ajouter l'addresse ip du reseau greygoose
<<<
     up ip addr add 192.168.0.1/24 dev enp0s31f6
    down ip addr del 192.168.0.1/24 dev enp0s31f6
>>>

Pour creer le reseau greygoose
reserved= 192.168.0.2 <> 192.168.0.31
ip-range= 192.168.0.32 <> 192.168.0.95

docker network create \
    --driver macvlan \
    --opt macvlan_mode=bridge \
    --opt parent=enp0s31f6 \
    --internal \
    --subnet 192.168.0.0/24 \
    --ip-range 192.168.0.64/26 \
    --aux-address "hostint=192.168.0.1" \
    greygoose
