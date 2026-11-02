#!/usr/bin/env bash
# CloudCore estate launcher.
#
# Students use this. It finds a container runtime, chooses the right Compose
# command, and hides the engine choice. The engine is an implementation detail,
# not the lesson.
#
#   ./start.sh                 show help
#   ./start.sh m03             start the Module 03 state
#   ./start.sh m06             start the cumulative Module 06 state
#   ./start.sh m09             start the cumulative Module 09 state
#   ./start.sh status          show what is running
#   ./start.sh console         shell on the tools container
#   ./start.sh logs [service]  follow logs
#   ./start.sh exec <svc> <cmd...>
#   ./start.sh run [opts] <svc> <cmd...>
#   ./start.sh restart <svc>
#   ./start.sh stats           one CPU and memory sample
#   ./start.sh inspect <svc> [format opts]
#   ./start.sh limit <svc> <cpus>
#   ./start.sh stop            stop, keep volumes
#   ./start.sh down            remove containers and networks, keep volumes
#   ./start.sh reset <m03|m06|m09>
#   ./start.sh fix-m09
#   ./start.sh break-m09
#   ./start.sh smoke
#   ./start.sh pull
#   ./start.sh guide           open the install simulation, then the host shell
#   ./start.sh host            start the Ubuntu host shell
#   ./start.sh host reset      remove the host shell and its home volume
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# macOS on an external drive leaves AppleDouble files that break Docker build
# contexts. They are not part of the lab.
find . -name '._*' -delete 2>/dev/null || true

# --- Pick the engine without asking the student ---------------------------
if [[ -n "${CONTAINER_ENGINE:-}" ]]; then
  ENGINE="$CONTAINER_ENGINE"
elif command -v docker >/dev/null 2>&1; then
  ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
  ENGINE="podman"
else
  cat >&2 <<'EOF'
No container runtime found.

Install Docker Desktop or Podman once, then run ./start.sh again.
See modules/module-00-setup/README.md for the short version.
EOF
  exit 1
fi

if [[ "$ENGINE" == "podman" ]]; then
  if podman compose version >/dev/null 2>&1; then
    COMPOSE=(podman compose)
  elif command -v podman-compose >/dev/null 2>&1; then
    COMPOSE=(podman-compose)
  else
    echo "Podman is installed but Compose support is missing. Install podman-compose." >&2
    exit 1
  fi
else
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker is installed but Compose is not available. Install Docker Compose." >&2
    exit 1
  fi
  COMPOSE=(docker compose)
fi

ALL_PROFILES=(--profile m03 --profile m06 --profile m09)

usage() {
  cat <<'EOF'
CloudCore estate launcher

  ./start.sh m03             start the Module 03 state
  ./start.sh m06             start the cumulative Module 06 state
  ./start.sh m09             start the cumulative Module 09 state
  ./start.sh status          show what is running
  ./start.sh console         shell on the tools container
  ./start.sh logs [service]  follow logs
  ./start.sh stop            stop, keep volumes
  ./start.sh down            remove containers and networks, keep volumes
  ./start.sh reset m03|m06|m09
  ./start.sh fix-m09         repair the finance share
  ./start.sh break-m09       put the finance share back into the broken state
  ./start.sh smoke           run the smoke test
  ./start.sh pull            pull the images
  ./start.sh guide           open the install simulation, then the host shell
  ./start.sh host            start the Ubuntu host shell
  ./start.sh host reset      remove the host shell and its home volume

Diagnostics:
  ./start.sh exec <service> <command...>
  ./start.sh run [opts] <service> <command...>
  ./start.sh restart <service>
  ./start.sh stats
  ./start.sh inspect <service> [format options]
  ./start.sh limit <service> <cpus>
EOF
}

state() {
  case "$1" in
    m03) "${COMPOSE[@]}" --profile m03 up -d ;;
    m06) "${COMPOSE[@]}" --profile m03 --profile m06 up -d ;;
    m09) "${COMPOSE[@]}" --profile m03 --profile m06 --profile m09 up -d ;;
    *)
      echo "Unknown state: ${1:-}" >&2
      echo "Use m03, m06 or m09." >&2
      exit 1
      ;;
  esac
}

service_cid() {
  local svc="$1" cid
  cid="$("${COMPOSE[@]}" "${ALL_PROFILES[@]}" ps -q "$svc" 2>/dev/null | sed -n '1p')"
  if [[ -z "$cid" ]]; then
    echo "Service '$svc' is not running. Start a state first: ./start.sh m03" >&2
    return 1
  fi
  printf '%s\n' "$cid"
}

start_host() {
  local image="cloudcore-host:latest"
  if ! "$ENGINE" image inspect "$image" >/dev/null 2>&1; then
    echo "Building the CloudCore host image (first run only)..."
    "$ENGINE" build -t "$image" -f host/Dockerfile host
  fi
  local tty_flags=(-i)
  if [[ -t 0 && -t 1 ]]; then
    tty_flags=(-it)
  fi
  "$ENGINE" rm -f cloudcore-host >/dev/null 2>&1 || true
  "$ENGINE" run --rm "${tty_flags[@]}" --name cloudcore-host --hostname cloudcore-host \
    -v cloudcore-host-home:/home/student "$image"
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  help|-h|--help)
    usage
    ;;

  m03|m06|m09)
    state "$cmd"
    case "$cmd" in
      m06) echo "Estate is up. Open https://localhost:8443 (expect a certificate warning)." ;;
      m09) echo "Estate is up, including the finance share." ;;
      *)   echo "Estate is up." ;;
    esac
    ;;

  status|ps)
    "${COMPOSE[@]}" ps
    ;;

  console)
    "${COMPOSE[@]}" --profile m03 exec tools sh
    ;;

  logs)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" logs --tail=100 -f "$@"
    ;;

  exec)
    svc="${1:-}"
    [[ -n "$svc" ]] || { echo "Usage: ./start.sh exec <service> <command...>" >&2; exit 1; }
    shift
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" exec "$svc" "$@"
    ;;

  run)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" run "$@"
    ;;

  restart)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" restart "$@"
    ;;

  stats)
    "$ENGINE" stats --no-stream
    ;;

  inspect)
    svc="${1:-}"
    [[ -n "$svc" ]] || { echo "Usage: ./start.sh inspect <service> [format options]" >&2; exit 1; }
    shift
    cid="$(service_cid "$svc")" || exit 1
    "$ENGINE" inspect "$@" "$cid"
    ;;

  limit)
    svc="${1:-}"
    cpus="${2:-}"
    [[ -n "$svc" && -n "$cpus" ]] || { echo "Usage: ./start.sh limit <service> <cpus>" >&2; exit 1; }
    cid="$(service_cid "$svc")" || exit 1
    "$ENGINE" update --cpus "$cpus" "$cid" >/dev/null
    echo "Set $svc to $cpus CPU."
    ;;

  stop)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" stop
    ;;

  down)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" down --remove-orphans
    ;;

  reset)
    target="${1:-}"
    case "$target" in
      m03|m06|m09) ;;
      *) echo "Usage: ./start.sh reset m03|m06|m09" >&2; exit 1 ;;
    esac
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" down -v --remove-orphans
    state "$target"
    echo "Estate reset to the Module ${target#m} state."
    ;;

  fix-m09)
    "${COMPOSE[@]}" --profile m09 run --rm --user root writer sh -c \
      'chown -R 1000:1000 /share && chmod 775 /share'
    echo "Finance share repaired."
    ;;

  break-m09)
    "${COMPOSE[@]}" --profile m09 run --rm --user root writer sh -c \
      'chown root:root /share && chmod 755 /share'
    echo "Finance share returned to the broken state."
    ;;

  smoke)
    CONTAINER_ENGINE="$ENGINE" ./tests/smoke.sh
    ;;

  guide)
    echo "Opening the install simulation..."
    case "$(uname -s)" in
      Darwin)
        open index.html 2>/dev/null || echo "Open this file in your browser: $(pwd)/index.html"
        ;;
      MINGW*|MSYS*|CYGWIN*)
        cmd.exe /c start "" index.html 2>/dev/null || echo "Open this file in your browser: $(pwd)/index.html"
        ;;
      *)
        if command -v xdg-open >/dev/null 2>&1; then
          xdg-open index.html 2>/dev/null || echo "Open this file in your browser: $(pwd)/index.html"
        else
          echo "Open this file in your browser: $(pwd)/index.html"
        fi
        ;;
    esac
    echo
    echo "Complete the simulation and download the build record."
    echo "Keep the build record for your portfolio."
    echo
    read -r -p "Press Enter when you are ready to start the host shell..." _
    start_host
    echo
    echo "When you are finished in the host shell, start the estate in a second terminal:"
    echo "  ./start.sh m03"
    ;;

  host)
    host_cmd="${1:-}"
    if [[ "$host_cmd" == "reset" ]]; then
      "$ENGINE" rm -f cloudcore-host >/dev/null 2>&1 || true
      "$ENGINE" volume rm cloudcore-host-home >/dev/null 2>&1 || true
      echo "Host shell reset. The next ./start.sh host starts clean."
      exit 0
    fi
    start_host
    ;;

  pull)
    "${COMPOSE[@]}" "${ALL_PROFILES[@]}" pull
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    echo "" >&2
    usage >&2
    exit 1
    ;;
esac
