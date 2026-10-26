Add-DnsServerPrimaryZone -NetworkId "10.10.10.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -ZoneName "10.10.10.in-addr.arpa" -Name "10" -PTRDomainName "DC01.novatech.local"