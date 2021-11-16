#!/bin/sh

podman build -ti -t aleph-vm-supervisor -f docker/vm_supervisor.dockerfile .
podman run -ti --rm \
  -v $(pwd):/root/aleph-vm \
  --device /dev/kvm \
  --privileged  \
  aleph-vm-supervisor \
  bash
#  python3 -m vm_supervisor -p -vv --system-logs --benchmark 1 --profile
