# Module 00: Environment setup

**Goal:** a working container engine and the lab repo running on your machine.

## 1. Install a container engine

- **Docker Desktop** for macOS or Windows, or **Docker Engine** on Linux.
- **Podman** is supported where Docker Desktop cannot be installed. On macOS or Windows,
  make sure the Podman machine is running.

Check:

```bash
docker --version
docker compose version
```

Or:

```bash
podman --version
podman compose version
```

## 2. Get the repo

```bash
git clone <repo-url>
cd enterprise-estate-labs
```

If you do not use Git, download the ZIP and unzip it.

## 3. Run the smoke test

```bash
make smoke
```

This brings up each state, checks the web tier and the TLS proxy, and removes everything
afterwards. It may take a few minutes the first time while images pull.

## 4. Run the first state

```bash
make m03
make status
make console
```

Inside the tools container:

```bash
curl http://web/
```

You should see the CloudCore estate page.

## If it fails

- **Port 8443 already in use:** stop the other service, or change the host port in
  `compose.yml`.
- **Permission errors on an external drive:** the repo avoids host bind mounts for data,
  but the compose file and config files still live on the drive. If Docker reports a
  problem with `._*` files, remove them or move the repo to an internal disk.
- **Podman permission errors:** try a rootful Podman machine if networking modules fail.
- **Apple Silicon:** the images used here are multi-architecture. If a future image is
  not, add a note in the module guide rather than silently falling back.
