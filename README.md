# OpenNebula XEN Monitor
XEN monitoring scripts for OpenNebula >= 5.10.

## Setup

1. Copy`xen.d` directory to `/var/lib/one/remotes/im`.
2. Copy `xen-probes.d` to `/var/lib/one/remotes/im`.
3. Sync up OpenNebula monitoring system: `$ onehost sync --ssh <host_id>`. You
   should now see host and it's VM updates in `/var/log/one/monitor.log`.
