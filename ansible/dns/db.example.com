$TTL 3600
$ORIGIN example.com.
@ IN SOA dnsserver.example.com. admin.example.com. (
                        2024081101      ; Serial
                        10800           ; Refresh
                        3600            ; Retry
                        604800          ; Expire
                        86400 )         ; Minimum TTL

; DNS Servers
@               IN NS   dnsserver.example.com.
dnsserver       IN A    192.168.0.250

; Machine Names
localhost       IN A    127.0.0.1
rocky           IN A    192.168.0.69

