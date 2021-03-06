# Changelog

## v4.1.0

- Improved installation script to build a basic but powerful firewall out of the box
- Installation script will try to find out default network interface name and replace "eth0" with it, in Iptables configuration files.

## v4.0.0

- Renamed the words in lists "whitelist", "blacklist" to "allowlist", "denylist" respectively
- Changed IP set structure

## v3.1.0

- Fixed an important bug prevents firewall starting correctly in standalone mode

## v3.0.0

- Changed IP set structure
- Swapped IP set names "blacklist" and "banlist". "whitelist" and "blacklist" are now for user, "banlist" is internally used by Iptables rules.
- Added timeout support to IP sets named "whitelist" and "blacklist"
- Added IP set named "seclist"
- Updated examples

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
