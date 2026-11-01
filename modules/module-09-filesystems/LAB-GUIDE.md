# Module 09: File systems and access control

**Ticket:** the reporting service cannot write to the finance share.

**Goal:** diagnose a permission failure on a shared volume, fix it without loosening
the whole share, and explain the ownership model.

## Before you start

```bash
make m09
make status
```

The `writer` service runs as user `1000:1000`. The shared volume is created by Docker as
root. On the first run, the writer cannot create `/share/report.log`.

## Part 1: Observe the failure

```bash
docker compose logs writer
```

1. What error do you see?
2. Which user is the writer running as?
3. Who owns `/share`?

Inspect the volume:

```bash
docker compose --profile m09 run --rm --user root writer sh -c 'ls -ld /share; ls -l /share'
```

**Predict before you act:** what is the smallest change that lets the writer create and
append to its own log file without giving it more access than it needs?

## Part 2: Fix it

```bash
make fix-m09
docker compose logs -f writer
```

You should see `report ok` lines. Stop following with `Ctrl-C`.

If the log still shows old `Permission denied` lines, they are history. Check the file
instead, or use `docker compose logs --since 15s writer`.

Check the file:

```bash
docker compose --profile m09 run --rm --user root writer sh -c 'ls -l /share; tail -n 3 /share/report.log'
```

## Part 3: Explain the fix

1. Why is `chmod 777` the wrong fix?
2. Why is group ownership better than making the file world-writable?
3. What would you change if a second service, running as a different user, also needed
   to write to the share?
4. What would you monitor so this fault is caught before a user reports it?

## Part 4: Put it back

```bash
make break-m09
docker compose logs writer
```

The failure returns. This is the reset point for the exercise.

## Evidence

- The `logs writer` error.
- The `ls -ld /share` output before and after the fix.
- The exact command you used, and why it is the smallest safe change.
- Your answer to the `chmod 777` question.
- One place where AI was wrong, vague or over-confident.

## AI prompts

- "A container runs as UID 1000 and a Docker named volume is owned by root. Explain why
  the write fails and what the smallest fix is."
- "Compare `chmod 777`, group ownership and an ACL for a shared directory used by two
  services."
- "Where does this explanation overreach? What does it leave out about UID mapping on the
  host and in rootless containers?"

## Clean up

```bash
make down
```
