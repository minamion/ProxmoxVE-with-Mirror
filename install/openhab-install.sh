#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/minamion/ProxmoxVE-with-Mirror/raw/main/LICENSE
# Source: https://www.openhab.org/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  gnupg \
  apt-transport-https
msg_ok "Installed Dependencies"

msg_info "Installing Azul Zulu21"
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB1998361219BD9C9" -o "/etc/apt/trusted.gpg.d/zulu-repo.asc"
curl -fsSL "https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb" -o $(basename "https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb")
$STD dpkg -i zulu-repo_1.0.0-3_all.deb
$STD apt-get update
$STD apt-get -y install zulu21-jdk
msg_ok "Installed Azul Zulu21"

msg_info "Installing openHAB"
curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor >openhab.gpg
mv openhab.gpg /usr/share/keyrings
chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg
echo "deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main" >/etc/apt/sources.list.d/openhab.list
$STD apt update
$STD apt-get -y install openhab
systemctl daemon-reload
systemctl enable -q --now openhab
msg_ok "Installed openHAB"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
