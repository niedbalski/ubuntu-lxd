#!/usr/bin/env python

try:
    import yaml
except:
    from charmhelpers.fetch import apt_install
    apt_install("python-yaml")
    import yaml


from charmhelpers.core.hookenv import (
    action_get,
    action_fail,
    action_set,
)

import subprocess
import traceback


def get_devices_by_container(name):
    return yaml.load(subprocess.check_output(
        ["lxc", "config", "device", "show", name]))


def filter_devices_by_type(name, device_type):
    for name, device in get_devices_by_container(name).items():
        if device['type'] == device_type:
            yield name, device


def remove_device(container, device):
    return subprocess.check_call([
        "lxc", "config", "device", "remove", container, device
    ])


def remove_devices():
    container = action_get(key="container")
    device_type = action_get(key="device.type")
    device_name = action_get(key="device.name")

    removed_devices = []
    for name, device in filter_devices_by_type(container, device_type):
        if name == device_name or 'parent' in device.keys() \
           and (device["parent"] == device_name or
                device["parent"] == "br-%s" % device_name):
            try:
                remove_device(container, name)
            except:
                action_set({'traceback': traceback.format_exc()})
                action_fail('Cannot remove device: %s from: %s' % (name,
                                                                   container))
            else:
                removed_devices.append(device_name)

    action_set({'removed': ",".join(removed_devices)})

if __name__ == "__main__":
    remove_devices()
