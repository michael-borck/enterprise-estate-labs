# Enterprise Estate Labs

> **Status:** prototype. The Module 03, 06 and 09 slice is built and tested. The rest
> of the estate follows once the cumulative-state pattern is proven in a real lab.

A self-contained, Docker-based enterprise estate for a first course in enterprise
technology. Students build, operate and secure one Linux and container estate across
the semester. The labs use real services: nginx, PostgreSQL, Caddy, named volumes,
permissions, logs and packet capture.

This repo is **unit-agnostic**. Modules are numbered by topic, not by any unit code.
See [`SCHEDULE.md`](SCHEDULE.md) to map them onto a teaching calendar.

The unit that uses it keeps the assessment, the CloudCore tickets and the weekly
teaching material in its own repo. This repo provides the runtime and the evidence
prompts.

## Quick start

You need Docker or Podman. See [`modules/module-00-setup/README.md`](modules/module-00-setup/README.md).

```bash
make m03        # web, db and tools
make m06        # cumulative: adds the TLS proxy
make m09        # cumulative: adds the shared volume and permission fault
make status
make console    # shell on the tools container
```

Or run `./start.sh` to bring up the Module 06 state and print the URLs.

Open <https://localhost:8443>. The certificate is self-signed, so the browser warning
is expected. That warning is part of Module 06.

Stop and reset:

```bash
make stop
make down
make reset-m09  # remove volumes and return to a clean Module 09 state
make smoke      # validate the three states end to end
```

Podman:

```bash
make m06 CONTAINER_ENGINE=podman
```

## What runs

| Module | State | Services |
|---|---|---|
| 03 | Containers and limits | `db` (PostgreSQL), `web` (nginx), `tools` (netshoot) |
| 06 | Web and TLS | adds `proxy` (Caddy, internal TLS) |
| 09 | File systems and access control | adds `writer` and a shared volume with a permission fault |

The states are cumulative. `make m06` also brings up Module 03. `make m09` also brings
up Modules 03 and 06. Nothing else runs.

## Design

- **One estate, cumulative states.** Module numbers are states, not independent labs.
- **One compose file.** Services are selected by profiles `m03`, `m06`, `m09`.
- **Resettable.** `make reset-mNN` removes volumes and returns to that state.
- **Offline-friendly.** Images are prebuilt. The only external access is the initial pull.
- **No host bind mounts for data.** Named volumes keep the labs portable across macOS,
  Windows and Linux, including external drives.
- **Student-owned artefact.** The lab repo is a toolkit. Students work in their own
  estate repository, which is what the portfolio assesses.

## Modules

| Module | Topic | Guide |
|---|---|---|
| 00 | Environment setup | [`modules/module-00-setup/README.md`](modules/module-00-setup/README.md) |
| 03 | Processes, memory and containers | [`modules/module-03-containers/LAB-GUIDE.md`](modules/module-03-containers/LAB-GUIDE.md) |
| 06 | Protocols and the web tier | [`modules/module-06-web-tls/LAB-GUIDE.md`](modules/module-06-web-tls/LAB-GUIDE.md) |
| 09 | File systems and access control | [`modules/module-09-filesystems/LAB-GUIDE.md`](modules/module-09-filesystems/LAB-GUIDE.md) |

Planned: 04 networking, 05 addressing and naming, 08 identity, 10 storage, 11 security
and incident response. The host VM bootstrap is planned for `host/`.

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
