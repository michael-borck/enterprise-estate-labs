# Module 00: Environment setup

**Goal:** a working container runtime, the CloudCore host shell running, and the first
estate state up.

This replaces the old "install VirtualBox and copy the Windows VM" step. There is no VM
here. The OS install is a simulation. The real host is an Ubuntu container shell, and the
estate services run in containers.

You do this once, before your first lab. Budget about 20 minutes, most of it waiting for
downloads.

> **You do not have to use your own laptop.** The lab machines already have Docker
> installed. This guide is for people who want the labs on their own computer as well.

## Before you start

- **Disk space:** about 10 GB free. The images are downloaded once.
- **Memory:** 8 GB RAM is comfortable; 4 GB works for most labs.
- **Network:** the first launch downloads roughly a gigabyte. On campus wifi that can take
  several minutes and looks like nothing is happening. Let it finish.
- **Admin rights:** you need to be able to install software. On a locked-down computer, use
  the lab machines instead.

## 1. Install a container runtime

You want **Docker Desktop** on Windows and macOS, or **Docker Engine** on Linux. **Podman**
is supported where Docker cannot be installed; the launcher finds either one.

### Windows

1. Download **[Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)**
   and run the installer. Accept the defaults, including **Use WSL 2**.
2. Restart when asked.
3. Start Docker Desktop and wait until the whale icon says **running**. The first start
   takes a minute or two.

If it complains about **WSL 2**, **virtualisation** or **Hyper-V**, see section 2.

### macOS

Download **[Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)**.
Choose the **Apple Silicon** build for an M-series Mac, or the **Intel** build for an older
one. Drag it to Applications, start it, and wait for *running*.

Macs have virtualisation built in, so there is no firmware step.

### Linux

Install **Docker Engine** and the **Compose plugin** from your distribution or from
[docs.docker.com/engine/install](https://docs.docker.com/engine/install/). Then let your
user talk to Docker without `sudo`:

```bash
sudo usermod -aG docker "$USER"
```

**Log out and back in** for that to take effect.

> Adding yourself to the `docker` group is effectively granting administrator rights,
> because anyone who can start a container can mount the filesystem into it. That is fine
> on your own machine, but hold the thought for the access-control module.

### Podman instead of Docker

Podman Desktop on Windows or macOS, or `podman` plus `podman-compose` on Linux, also works.
The launcher detects it. On macOS or Windows, start the Podman machine first. On Linux,
rootless Podman is preferred.

### Check it worked

Open a terminal and run:

```bash
docker run --rm hello-world
docker compose version
```

Or, with Podman:

```bash
podman run --rm hello-world
podman compose version
```

The first command prints a short welcome message. If both work, continue.

## 2. Windows only: turning on virtualisation

Docker runs Linux containers, which needs the CPU virtualisation feature. On most modern
laptops it is already on. Try installing Docker first.

If Task Manager shows **Virtualisation: Disabled**, you have two options:

1. **WSL 2.** Open PowerShell as administrator and run:

   ```powershell
   wsl --install
   wsl --update
   ```

   Restart, start Docker Desktop, and try `docker run --rm hello-world` again. This works on
   Windows 10 (2004 or later) and Windows 11, Home or Pro. You do not need Hyper-V.

2. **Firmware.** If WSL is not enough, enable **Intel VT-x** or **AMD-V** in the laptop's
   firmware. The setting is under **Advanced**, **CPU Configuration**, **Security** or
   **Configuration**. Change only that one setting. If the firmware is password-protected,
   use the lab machines.

## 3. Get the lab pack

Download the ZIP and unzip it:

**https://github.com/michael-borck/enterprise-estate-labs/archive/refs/heads/main.zip**

Or, if you have Git:

```bash
git clone https://github.com/michael-borck/enterprise-estate-labs.git
cd enterprise-estate-labs
```

> **Windows note:** "Extract All" puts the contents inside a new folder. The inner folder,
> the one containing `start.bat`, is the one you want.

### Where to put it

Unzip or clone into a local folder you can find again, for example
`Documents\enterprise-estate-labs`. Avoid running from Downloads, OneDrive, a network drive
or a USB stick if you can. Docker builds and file permissions are simpler on a local disk.

The launcher runs in the folder where `start.bat` or `start.sh` sits. It does not keep
running from your Downloads folder after you unzip. Docker stores images, containers and
volumes in its own area, not in the lab folder. The host home directory is a Docker volume
named `cloudcore-host-home`.

## 4. Start the host shell

The simulation is at `host/install-simulation.html` in the lab pack, or on the unit page.
The launcher is in the lab pack root, one level above that file. Open a terminal there.

The host shell is your Ubuntu Server. It is where you do the OS work: users, packages,
services, permissions and configuration.

```bash
./start.sh host
```

On Windows, use `start.bat`, not `start.sh`. In File Explorer, double-click `start.bat`,
or open PowerShell in the folder and run:

```powershell
.\start.bat host
```

If you double-click `start.bat` with no command, it shows the command list and waits.

The simulation does not install Docker and does not run the lab. It records the install
decisions. Section 1 and section 3 are the real setup.

The first run builds a small Ubuntu image. When the shell opens, you are the `student`
user. The default password for `sudo` is `cloudcore`. Change it in your first session:

```bash
passwd
```

Your home directory is kept between sessions. To start completely clean:

```bash
./start.sh host reset
```

The install simulation on your unit page shows the choices behind this host: the release,
the disk layout, the user, SSH and the package set. The same file is in the lab pack at
`host/install-simulation.html`.

## 5. Start the estate

In a second terminal, from the same folder:

```bash
./start.sh m03
./start.sh status
./start.sh console
```

The estate is the CloudCore service pod: a web tier, a database and a tools container. The
host shell is the Ubuntu machine. The estate runs on the same container runtime.

The full command set is in the main [README](../../README.md). You do not need to type
Docker or Podman commands. `./start.sh` hides the engine.

## 6. How a lab works

- **Start:** `./start.sh host` for the Ubuntu shell, or `./start.sh m03` for the estate.
- **Work:** follow the module's `LAB-GUIDE.md`. Use the host shell for OS work and the
  estate commands for services.
- **Record:** keep the commands, output and your predictions. That is your evidence.
- **Stop:** `./start.sh stop` stops the estate; `./start.sh down` removes the containers.
  The host shell exits with `exit`.

## If it doesn't work

**Check these first:**

1. **Is the runtime running?** Docker Desktop and the Podman machine must be started.
2. **Are you in the right folder?** The one containing `start.sh`, `start.bat` and
   `start.command`.
3. **The first run downloads a lot.** It can look frozen. Let it finish.

### Windows

| What you see | What it means |
|---|---|
| A window flashes open and disappears | You probably double-clicked `start.sh`, which Windows cannot run. Double-click `start.bat` instead. If `start.bat` also closes, Git for Windows or Docker is missing; the launcher should pause with a message. |
| I double-clicked `start.bat` and only see a command list | That is the no-argument help. Run `.\start.bat host` or `.\start.bat m03`. |
| PowerShell says it cannot run `start.sh` | Use `.\start.bat host`. Do not run `start.sh` directly on Windows. |
| The folder is in Downloads and things fail | Move the inner folder to Documents or another local folder. Avoid OneDrive, network drives and USB sticks. |
| A virtualisation or WSL 2 error | See section 2. |
| `bash` is not recognised | Install Git for Windows. It includes Git Bash and the launcher. |
| Cannot connect to the Docker daemon | Start Docker Desktop and wait for *running*. |

### macOS

| What you see | What it means |
|---|---|
| "cannot be opened because it is from an unidentified developer" | Right-click `start.command`, choose Open, then Open again. |
| Cannot connect to the Docker daemon | Start Docker Desktop and wait for *running*. |
| Double-clicking `start.sh` opens a text editor | Use `start.command` or run `./start.sh` in Terminal. |

### Linux

| What you see | What it means |
|---|---|
| Permission denied on `/var/run/docker.sock` | Add yourself to the `docker` group, then log out and back in. |
| `docker: command not found` | Install Docker Engine and the Compose plugin. |
| `docker compose` unknown but `docker-compose` works | You have Compose v1. Install the v2 plugin. |

### Everything else

| Symptom | Fix |
|---|---|
| A container exits immediately | `./start.sh logs <service>` or `docker logs <name>`. |
| Port 8443 already in use | Another estate is running. `./start.sh down`, then try again. |
| Build fails with an xattr or `._` error | Remove AppleDouble files: `find . -name '._*' -delete`. |
| Downloads fail or time out | A VPN or restrictive network is blocking the registry. Try without the VPN, or use the lab. |
| Out of disk space | `docker system prune` reclaims old images and containers. |

Bring anything else to the lab. The machines are set up and ready.
