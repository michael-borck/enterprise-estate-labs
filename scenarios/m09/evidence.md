# Evidence: Module 09

Record these in your portfolio or conversation log.

| Item | What to capture |
|---|---|
| Failure | `docker compose logs writer` and the permission error |
| State | `ls -ld /share` and `ls -l /share` before the fix |
| Fix | The exact command and why it is the smallest safe change |
| Result | Ownership and file contents after the fix |
| Judgement | Why `chmod 777` is wrong, and what you would monitor |
| Break | The result of `make break-m09` and the returned failure |

## Challenge prompt

Ask an AI assistant for the fix. Then ask it what could go wrong with that fix on a
rootless container or a shared host. Record one thing it missed.
