iptables -A INPUT -s 10.0.1.0/24 -j ACCEPT
iptables -A OUTPUT -d 10.0.1.0/24 -j ACCEPT
iptables -A FORWARD -s 10.0.1.0/24 -j ACCEPT
iptables -A FORWARD -d 10.0.1.0/24 -j ACCEPT

iptables -A INPUT -s 10.0.20.0/24 -j ACCEPT
iptables -A OUTPUT -d 10.0.20.0/24 -j ACCEPT
iptables -A FORWARD -s 10.0.20.0/24 -j ACCEPT
iptables -A FORWARD -d 10.0.20.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 179 -j ACCEPT     
iptables -A INPUT -p 4 -j ACCEPT                   
iptables -A OUTPUT -p 4 -j ACCEPT

iptables -A INPUT -p udp --dport 4789 -j ACCEPT
iptables -A OUTPUT -p udp --sport 4789 -j ACCEPT