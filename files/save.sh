#!/usr/bin/env bash

###
# sptables - Pure Iptables firewall for servers
#
# Copyright (c) 2018, Volkan Kucukcakar
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

###
# This file is a part of sptables - Pure Iptables firewall for servers
# Filename		: save.sh
# Path			: /etc/sptables/save.sh
# Description	: Manually save current sets without restarting service (Can be executed manually)
###


# ipset command
IPSET="ipset"

# Abort script on error
set -e

# Save current sets
echo "Saving current sets"
if $IPSET list whitelist >/dev/null 2>&1; then
	$IPSET save whitelist -f /etc/sptables/data/whitelist.save
fi
if $IPSET list blacklist >/dev/null 2>&1; then
	$IPSET save blacklist -f /etc/sptables/data/blacklist.save
fi
if $IPSET list proxylist >/dev/null 2>&1; then
	$IPSET save proxylist -f /etc/sptables/data/proxylist.save
fi
if $IPSET list crawlerlist >/dev/null 2>&1; then
	$IPSET save crawlerlist -f /etc/sptables/data/crawlerlist.save
fi
if $IPSET list bogonlist >/dev/null 2>&1; then
	$IPSET save bogonlist -f /etc/sptables/data/bogonlist.save
fi
if $IPSET list banlist >/dev/null 2>&1; then
	$IPSET save banlist -f /etc/sptables/data/banlist.save
fi

echo "Save script executed"
