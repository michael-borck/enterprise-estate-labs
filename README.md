# Enterprise Estate Labs

> **Status:** prototype. The Module 03, 05, 06, 08, 09, 10 and 11 states are built and
> tested. The lab estate now covers the full ISYS2008 arc.

A self-contained, container-based enterprise estate for a first course in enterprise
technology. Students build, operate and secure one Linux and container estate across
the semester. The labs use real services: nginx, PostgreSQL, Caddy, named volumes,
permissions, logs and packet capture.

This repo is **unit-agnostic**. Modules are numbered by topic, not by any unit code.
See [`SCHEDULE.md`](SCHEDULE.md) to map them onto a teaching calendar.

The unit that uses it keeps the assessment, the CloudCore tickets and the weekly
teaching material in its own repo. This repo provides the runtime and the evidence
prompts.

## Quick start

Install a container runtime once. Docker Desktop and Podman both work; the launcher
finds whichever is installed. See [`modules/module-00-setup/README.md`](modules/module-00-setup/README.md).

```bash
git clone https://github.com/michael-borck/enterprise-estate-labs.git
cd enterprise-estate-labs
./start.sh guide  # install simulation, then the Ubuntu host shell
./start.sh m03    # the CloudCore estate
./start.sh m05    # the estate plus internal DNS
./start.sh m08    # the estate plus identity and access
./start.sh m10    # the estate plus backup and restore
./start.sh m11    # the estate plus security and incident response
```

On Windows, use `start.bat guide` and `start.bat m03`.

The launcher is the front door. You do not choose an engine.

| Command | What it does |
|---|---|
| `./start.sh guide` | Open the install simulation, then the host shell |
| `./start.sh host` | Start the Ubuntu host shell |
| `./start.sh host reset` | Remove the host shell and its home volume |
| `./start.sh m03` | Start the Module 03 state: web, db and tools |
| `./start.sh m05` | Start the cumulative Module 05 state and add internal DNS |
| `./start.sh m06` | Start the cumulative Module 06 state and add the TLS proxy |
| `./start.sh m08` | Start the cumulative Module 08 state and add identity and access |
| `./start.sh m09` | Start the cumulative Module 09 state and add the shared volume |
| `./start.sh m10` | Start the cumulative Module 10 state and add backup and restore |
| `./start.sh m11` | Start the cumulative Module 11 state and add security logging |
| `./start.sh status` | Show what is running |
| `./start.sh console` | Shell on the tools container |
| `./start.sh logs` | Follow the logs |
| `./start.sh stop` | Stop the estate, keep the volumes |
| `./start.sh down` | Remove the containers and networks, keep the volumes |
| `./start.sh reset m09` | Remove the volumes and return to a clean Module 09 state |
| `./start.sh fix-m05` | Restore the portal DNS record |
| `./start.sh break-m05` | Point the portal name at the wrong address |
| `./start.sh fix-m08` | Restore the reporting group membership |
| `./start.sh break-m08` | Remove the reporting service from the reporting group |
| `./start.sh fix-m10` | Restore the backup command to include data |
| `./start.sh break-m10` | Put the backup back into the schema-only fault |
| `./start.sh fix-m11` | Close the admin leak and rotate the secret |
| `./start.sh break-m11` | Reintroduce the admin leak and the weak secret mode |
| `./start.sh check-m11` | Verify the leak is closed and the secret is rotated |
| `./start.sh smoke` | Validate all seven states end to end |

Open <https://localhost:8443>. The certificate is issued by a local authority, so the
browser warning is expected. That warning is part of Module 06.

## The host

The host is an Ubuntu container shell. The operating-system install is a browser
simulation: open [`index.html`](index.html) in the lab pack root, or use the online copy at
<https://install-sim.borck.education/>. The real host is the userland you
configure with `./start.sh host`.

## What runs

| Module | State | Services |
|---|---|---|
| 03 | Containers and limits | `db` (PostgreSQL), `web` (nginx), `tools` (network shell) |
| 04 | Networking models | uses the Module 03 state; capture in `tools` |
| 05 | Addressing and naming | adds the `dns` service and the portal name |
| 06 | Web and TLS | adds `proxy` (Caddy, internal TLS) |
| 08 | Identity and access | adds `identity` with users, groups, reports and a sudo rule |
| 09 | File systems and access control | adds `writer` and a shared volume with a permission fault |
| 10 | Storage, virtualisation and cloud | adds `backup` and a backup volume with a schema-only fault |
| 11 | Security and incident response | adds `logs`, a security log, an exposed admin page and a weak secret |

The states are cumulative. `./start.sh m05` also brings up Module 03. `./start.sh m06`
also brings up Modules 03 and 05. `./start.sh m08` also brings up 03, 05 and 06.
`./start.sh m09` also brings up 03, 05, 06 and 08. `./start.sh m10` brings up all of them
and adds backup and restore. `./start.sh m11` brings up the full estate and adds the
security incident. Nothing else runs.

## Modules

| Module | Topic | Guide |
|---|---|---|
| 00 | Environment setup | [`modules/module-00-setup/README.md`](modules/module-00-setup/README.md) |
| 03 | Processes, memory and containers | [`modules/module-03-containers/LAB-GUIDE.md`](modules/module-03-containers/LAB-GUIDE.md) |
| 04 | Networking models | [`modules/module-04-networking/LAB-GUIDE.md`](modules/module-04-networking/LAB-GUIDE.md) |
| 05 | Addressing and naming | [`modules/module-05-naming/LAB-GUIDE.md`](modules/module-05-naming/LAB-GUIDE.md) |
| 06 | Protocols and the web tier | [`modules/module-06-web-tls/LAB-GUIDE.md`](modules/module-06-web-tls/LAB-GUIDE.md) |
| 08 | Identity and access | [`modules/module-08-identity/LAB-GUIDE.md`](modules/module-08-identity/LAB-GUIDE.md) |
| 09 | File systems and access control | [`modules/module-09-filesystems/LAB-GUIDE.md`](modules/module-09-filesystems/LAB-GUIDE.md) |
| 10 | Storage, virtualisation and cloud | [`modules/module-10-storage/LAB-GUIDE.md`](modules/module-10-storage/LAB-GUIDE.md) |
| 11 | Security and incident response | [`modules/module-11-security/LAB-GUIDE.md`](modules/module-11-security/LAB-GUIDE.md) |

The host shell and install simulation are in `host/`. The estate covers the full arc; a new
module is added as a new state, not as a separate topology.

## Design

- **One estate, cumulative states.** Module numbers are states, not independent labs.
- **One compose file.** Services are selected by profiles `m03`, `m05`, `m06`, `m08`, `m09`, `m10`, `m11`.
- **Resettable.** `./start.sh reset mNN` removes volumes and returns to that state.
- **Offline-friendly.** Images are prebuilt. The only external access is the initial pull.
- **No host bind mounts for data.** Named volumes keep the labs portable across macOS,
  Windows and Linux, including external drives.
- **Student-owned artefact.** The lab repo is a toolkit. Students work in their own
  estate repository, which is what the portfolio assesses.

## For staff and advanced users

`./start.sh` hides the engine choice. The `Makefile` is the staff and CI path, and it
supports either engine:

```bash
make m09
make smoke
make m09 CONTAINER_ENGINE=podman
```

The compose file is engine-neutral. There is one set of labs, not two.

## AI use

Use AI as a conversation partner. Before each significant action, write what you expect
to happen. After it, compare. Record at least one place the AI was wrong, vague or
over-confident. The unit assesses that record; this repo only asks for it.

## Security

The estate is a teaching environment, not a production deployment. Do not expose it to
an untrusted network. The Module 06 certificate is deliberately self-signed. The
Module 09 share is deliberately misconfigured until you fix it.

## Licence

MIT. See [`LICENSE`](LICENSE).
