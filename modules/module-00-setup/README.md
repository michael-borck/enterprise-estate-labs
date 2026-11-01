# Module 00: Environment setup

**Goal:** a working container runtime and the lab repo running on your machine.

## 1. Install a container runtime

Install Docker Desktop (macOS or Windows) or Docker Engine (Linux). Podman also works
where Docker cannot be installed.

You do this once. The launcher finds whichever is installed, so you do not need to
choose or configure an engine.

## 2. Get the repo

```bash
git clone <repo-url>
cd enterprise-estate-labs
```

If you do not use Git, download the ZIP and unzip it.

## 3. Run the smoke test

```bash
./start.sh smoke
```

On Windows, use `start.bat smoke`. This brings up each state, checks the web tier and
the TLS proxy, and removes everything afterwards. It may take a few minutes the first
time while the images pull.

## 4. Run the first state

```bash
./start.sh m03
./start.sh status
./start.sh console
```

Inside the tools container:

```bash
curl http://web/
```

You should see the CloudCore estate page.

## If it fails

- **The launcher says no runtime:** install Docker Desktop or Podman, then run
  `./start.sh` again.
- **Port 8443 already in use:** stop the other service, or change the host port in
  `compose.yml`.
- **Permission errors on an external drive:** the repo avoids host bind mounts for data,
  but the compose file and config files still live on the drive. If the runtime reports a
  problem with `._*` files, remove them or move the repo to an internal disk.
- **Podman networking errors:** try a rootful Podman machine.
- **Apple Silicon:** the images used here are multi-architecture. If a future image is
  not, add a note in the module guide rather than silently falling back.
