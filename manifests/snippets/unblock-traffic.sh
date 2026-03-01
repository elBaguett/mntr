
ufw disable

iptables -F
iptables -X

iptables -A INPUT -p tcp --dport 179 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 179 -j ACCEPT

iptables -A INPUT -p 4 -j ACCEPT
iptables -A OUTPUT -p 4 -j ACCEPT

iptables -A INPUT -p udp --dport 4789 -j ACCEPT
iptables -A OUTPUT -p udp --sport 4789 -j ACCEPT

iptables -A FORWARD -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 10.0.0.0/8 -d 10.0.0.0/8 -j ACCEPT
iptables -A FORWARD -j ACCEPT

netfilter-persistent save

iptables-save > /etc/iptables/rules.v4

ufw allow 179/tcp
ufw allow proto 4
ufw allow 4789/udp
ufw allow from 192.168.0.0/16
ufw allow from 10.0.0.0/8
calicoctl node status
