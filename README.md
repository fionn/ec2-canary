# EC2 Canary

This deploys a canary _server_ to AWS EC2.
It's not much use if the server is directly accessible from the internet (we'd just get alerted all the time and it wouldn't indicate anything), so it's in a VPC with two other hosts.
These other hosts are accessible, and can communicate with the canary too, so the canary will alert if an attacker attempts to pivot.

This is a proof of concept; the intention is to provide a simple example that can be built on for more complex deployments, particularly those that make liberal use of VPCs.
