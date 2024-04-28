# ------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# ------------------------------------
import json
import subprocess
import time

node_config = json.loads(subprocess.check_output(["/opt/cycle/jetpack/bin/jetpack", "config", "--json"]))['cyclecloud']['node']
cluster_config = json.loads(subprocess.check_output(["/opt/cycle/jetpack/bin/jetpack", "config", "--json"]))['cyclecloud']['cluster']
hostname_update_config = json.loads(subprocess.check_output(["/opt/cycle/jetpack/bin/jetpack", "config", "--json"]))['hostname_update']
ip_address = json.loads(subprocess.check_output(["/opt/cycle/jetpack/bin/jetpack", "config", "--json"]))['ipaddress']
server_suffix = json.loads(subprocess.check_output(["/opt/cycle/jetpack/bin/jetpack", "config", "--json"]))['pbspro']['server_suffix']

node_template = node_config['template']
node_name = node_config['name']
node_number = node_name.split('-')[-1]
node_prefix = hostname_update_config['node_name_prefix']
cluster_name = cluster_config['name']

if node_prefix == "Cluster Prefix":
    prefix = cluster_name
else:
    prefix = node_prefix

if 'server' in node_name:
    targetHostname = prefix + server_suffix
else:
    targetHostname = '-'.join([prefix, node_template, node_number])

subprocess.check_output(['hostnamectl', 'set-hostname', targetHostname])
subprocess.check_output(['nmcli', "connection", "modify", "System eth0", 'ipv4.dhcp-hostname', targetHostname])
subprocess.check_output(['systemctl', 'restart', 'NetworkManager'])

seconds = 0
while True:
    if targetHostname not in subprocess.check_output(['nslookup', ip_address]).decode():
        print('Hostname not registered in DNS yet. Wait 2 seconds ...')
        time.sleep(2)
        seconds += 2
    else:
        print('Hostname successfully registered in {} seconds'.format(seconds))
        break
