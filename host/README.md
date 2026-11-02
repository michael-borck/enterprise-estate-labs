# Host

The host layer is an Ubuntu container shell, not a virtual machine. The operating-system
install is a browser simulation. The real host is the container userland you configure
afterwards.

## What is here

| File | Purpose |
|---|---|
| `Dockerfile` | Builds `cloudcore-host:latest`: Ubuntu 24.04 with `sudo`, common tools and a `student` user |
| `../index.html` | The browser-based install exercise: release, network, storage, user, SSH and packages |
| `../start.sh host` | Builds the image on first use and opens the shell |
| `../start.sh host reset` | Removes the shell and its home volume |

## Why a container, not a VM

A local VM needs a hypervisor that works on macOS Apple Silicon, Windows and Linux. That is
three paths, or one path with poor Apple Silicon support. A container host avoids the
hypervisor, runs on lab machines and student laptops, and starts in seconds.

The trade-off is honest: a container shares the host kernel. It has no boot process, no
partition table and no kernel installation. The simulation covers those decisions. The
container is the userland where you do the OS work.

## What the host can do

- Install packages with `apt`.
- Create users and groups, set passwords and configure `sudo`.
- Inspect processes, memory and disk.
- Configure permissions and ownership.
- Use the container network: addresses, routes, ports, DNS and `tcpdump`.
- Configure files, services and logs.

## What it cannot do

- Install a kernel or bootloader.
- Partition a real disk.
- Configure the physical host or its hardware.
- Run `systemd` as PID 1 in the default container.

The simulation covers the install and boot decisions. The host shell covers the
configuration work.

## Try it

The online copy is at <https://michael-borck.github.io/enterprise-estate-labs/>.

First time:

```bash
./start.sh guide
```

That opens `../index.html`, waits while you complete the simulation, then starts the host
shell. If you have already done the simulation:

```bash
./start.sh host
```

The default `sudo` password is `cloudcore`. Change it with `passwd`. Your home directory is
kept in the `cloudcore-host-home` volume.

The simulation sits in the lab pack root, next to `start.bat` and `start.sh`.
