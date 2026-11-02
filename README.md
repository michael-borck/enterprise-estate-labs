# Enterprise Estate Labs

> **Status:** prototype. The Module 03, 06 and 09 slice is built and tested. The rest
> of the estate follows once the cumulative-state pattern is proven in a real lab.

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
```

On Windows, use `start.bat guide` and `start.bat m03`.

The launcher is the front door. You do not choose an engine.

| Command | What it does |
|---|---|
| `./start.sh guide` | Open the install simulation, then the host shell |
| `./start.sh host` | Start the Ubuntu host shell |
| `./start.sh host reset` | Remove the host shell and its home volume |
| `./start.sh m03` | Start the Module 03 state: web, db and tools |
| `./start.sh m06` | Start the cumulative Module 06 state and add the TLS proxy |
| `./start.sh m09` | Start the cumulative Module 09 state and add the shared volume |
| `./start.sh status` | Show what is running |
| `./start.sh console` | Shell on the tools container |
| `./start.sh logs` | Follow the logs |
| `./start.sh stop` | Stop the estate, keep the volumes |
| `./start.sh down` | Remove the containers and networks, keep the volumes |
| `./start.sh reset m09` | Remove the volumes and return to a clean Module 09 state |
| `./start.sh smoke` | Validate all three states end to end |

Open <https://localhost:8443>. The certificate is issued by a local authority, so the
browser warning is expected. That warning is part of Module 06.

## The host

The host is an Ubuntu container shell. The operating-system install is a browser
simulation: open [`index.html`](index.html) in the lab pack root. The real host is the
userland you configure with `./start.sh host`.

## What runs

| Module | State | Services |
|---|---|---|
| 03 | Containers and limits | `db` (PostgreSQL), `web` (nginx), `tools` (network shell) |
| 06 | Web and TLS | adds `proxy` (Caddy, internal TLS) |
| 09 | File systems and access control | adds `writer` and a shared volume with a permission fault |

The states are cumulative. `./start.sh m06` also brings up Module 03. `./start.sh m09`
also brings up Modules 03 and 06. Nothing else runs.

## Modules

| Module | Topic | Guide |
|---|---|---|
| 00 | Environment setup | [`modules/module-00-setup/README.md`](modules/module-00-setup/README.md) |
| 03 | Processes, memory and containers | [`modules/module-03-containers/LAB-GUIDE.md`](modules/module-03-containers/LAB-GUIDE.md) |
| 06 | Protocols and the web tier | [`modules/module-06-web-tls/LAB-GUIDE.md`](modules/module-06-web-tls/LAB-GUIDE.md) |
| 09 | File systems and access control | [`modules/module-09-filesystems/LAB-GUIDE.md`](modules/module-09-filesystems/LAB-GUIDE.md) |

Planned: 04 networking, 05 addressing and naming, 08 identity, 10 storage, 11 security
and incident response. The host shell and install simulation are in `host/`.

## Design

- **One estate, cumulative states.** Module numbers are states, not independent labs.
- **One compose file.** Services are selected by profiles `m03`, `m06`, `m09`.
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
