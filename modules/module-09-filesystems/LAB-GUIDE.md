# Module 09: File systems and access control

**Ticket:** the reporting service cannot write to the finance share.

**Goal:** diagnose a permission failure on a shared volume, fix it without loosening
the whole share, and explain the ownership model.

## Before you start

```bash
./start.sh m09
./start.sh status
```

The `writer` service runs as user `1000:1000`. The shared volume is created as root. On
the first run, the writer cannot create `/share/report.log`.

The launcher finds the container runtime for you. You do not need to choose one.

## Part 1: Observe the failure

```bash
./start.sh logs writer
```

1. What error do you see?
2. Which user is the writer running as?
3. Who owns `/share`?

Inspect the volume:

```bash
./start.sh run --rm --user root writer sh -c 'ls -ld /share; ls -l /share'
```

**Predict before you act:** what is the smallest change that lets the writer create and
append to its own log file without giving it more access than it needs?

## Part 2: Fix it

```bash
./start.sh fix-m09
./start.sh logs writer
```

You should see `report ok` lines. Stop following with `Ctrl-C`.

If the log still shows old `Permission denied` lines, they are history. Check the file
instead.

Check the file:

```bash
./start.sh run --rm --user root writer sh -c 'ls -l /share; tail -n 3 /share/report.log'
```

## Part 3: Explain the fix

1. Why is `chmod 777` the wrong fix?
2. Why is group ownership better than making the file world-writable?
3. What would you change if a second service, running as a different user, also needed
   to write to the share?
4. What would you monitor so this fault is caught before a user reports it?

## Part 4: Put it back

```bash
./start.sh break-m09
./start.sh logs writer
```

The failure returns. This is the reset point for the exercise.

## Evidence

- The `logs writer` error.
- The `ls -ld /share` output before and after the fix.
- The exact command you used, and why it is the smallest safe change.
- Your answer to the `chmod 777` question.
- One place where AI was wrong, vague or over-confident.

## AI prompts

- "A container runs as UID 1000 and a named volume is owned by root. Explain why the
  write fails and what the smallest fix is."
- "Compare `chmod 777`, group ownership and an ACL for a shared directory used by two
  services."
- "Where does this explanation overreach? What does it leave out about UID mapping on the
  host and in rootless containers?"

## Clean up

```bash
./start.sh down
```
