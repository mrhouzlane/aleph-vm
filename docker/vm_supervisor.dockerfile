# This is mainly a copy of the installation instructions from [vm_supervisor/README.md]

FROM debian:bullseye

RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    sudo acl curl systemd-container  \
    python3 python3-aiohttp python3-msgpack python3-pip python3-aiodns python3-aioredis \
    squashfs-tools python3-psutil debootstrap iputils-ping iptables iproute2 redis openssh-client htop \
    && rm -rf /var/lib/apt/lists/*

RUN useradd jailman

RUN mkdir /opt/firecracker
RUN chown $(whoami) /opt/firecracker
RUN curl -fsSL https://github.com/firecracker-microvm/firecracker/releases/download/v0.24.2/firecracker-v0.24.2-x86_64.tgz | tar -xz --directory /opt/firecracker
RUN curl -fsSL -o /opt/firecracker/vmlinux.bin https://github.com/aleph-im/aleph-vm/releases/download/0.1.0/vmlinux.bin

# Link binaries on version-agnostic paths:
RUN ln /opt/firecracker/firecracker-v* /opt/firecracker/firecracker
RUN ln /opt/firecracker/jailer-v* /opt/firecracker/jailer

RUN pip3 install typing-extensions 'aleph-message>=0.1.18'
RUN pip3 install pytest pytest-asyncio

RUN mkdir /srv/jailer

ENV PYTHONPATH /mnt

ENV ALEPH_VM_NETWORK_INTERFACE "tap0"
# Jailer does not work in Docker containers
ENV ALEPH_VM_USE_JAILER False
# Use fake test data
ENV ALEPH_VM_FAKE_DATA True

# Make it easy to enter this command from a shell script
RUN echo "ssh root@172.0.5.2" >> /root/.bash_history
RUN echo "python3 -m vm_supervisor -p -vv --system-logs --benchmark 1 --profile" >> /root/.bash_history
RUN echo "pytest -vv -x ./vm_supervisor" >> /root/.bash_history

WORKDIR /root/aleph-vm
