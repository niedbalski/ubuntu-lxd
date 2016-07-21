## Current implemented actions

* remove-device: Remove a specific device from a given guest.

Example usage:

```bash
$ git clone github.com/niedbalski/ubuntu-lxd ubuntu-lxd
$ juju deploy ./ubuntu-lxd --to 0 --series xenial 
```
The following action will remove the device eth0 (mapped to br-esn3) on the container juju-34ecda-0-lxd-1
```
$ juju run-action ubuntu-lxd/0 remove-device container=juju-34ecda-0-lxd-1 device.name="br-ens3" device.type="nic"
```
The following is also supported:
```
$ juju run-action ubuntu-lxd/0 remove-device container=juju-34ecda-0-lxd-1 device.name="eth0" device.type="nic"
```
All the LXD guests from a given host (ubuntu-lxd/0)
```bash
$ for unit in $(juju status | grep ubuntu-lxd/0 | grep -Po '.*\/[0-9]+' | awk '{print $4}'); do juju status | grep $unit | grep -Po 'juju\-.*[0-9]+' | xargs -icontainer juju run-action ubuntu-lxd/0 remove-device container=container device.name="eth0" device.type="nic"; done
```
