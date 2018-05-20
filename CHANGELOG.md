# Changelog

## v2.0.0

- Renamed to sptables (sptables - Pure Iptables firewall for servers)
- Still Docker compatible
- Added standalone mode (can run both with or without Docker)
- Slightly changed file structure

## v1.1.0

- Added proxylist to bypass connection limits for certain ports. Intended to be used as trusted reverse proxy / CDN IP addresses list
- Added dtables.save.sh to manually save current sets
- Fixed http/https ports used with connlimit at iptables.conf

## v1.0.0

- Initial release (Formerly: dtables - Docker compatible Iptables firewall)
