# Wake Host Daemon

If you have a local DNS-Server Running and an other server that goes to sleep; but hat wake on lan (WOL) enabled you can use this script to wake your sleeping server with a magic package every time the DNS of your sleeping server is queried. 

This script is an alternative to wake_host.py but relies on shell capabilities to achive the results. So it uses less system ressources.

# Config
Change the values in etc/config/wake_host_shell to the desired values

# Install

## Prequisites

You need the package `tcpdump` and `etherwake` installed.

## Install on local DNS

Just copy the files to the corresponding destinations on your local DNS. 

To enable the service when the server restarts
 `/etc/init.d/wake_host_shell enable` 

Note: You might need to flag /etc/init.d/wake_host and /usr/bin/wake_host.sh executable before you can to this.
 `chmod +x /etc/init.d/wake_host_shell`
 `chmod +x /usr/bin/wake_host.sh`

To immediately start the service use
 `/etc/init.d/wake_host_shell start`

Look in the syslog for entries indicating start/stop and dns capture.
