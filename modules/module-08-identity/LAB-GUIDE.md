# Module 08: Identity and access

**Ticket:** the reporting service cannot read the finance report, and a contractor needs
read-only access to the same report.

**Goal:** diagnose a missing group membership, fix it with the smallest safe change, tell
authentication apart from authorisation, and recommend the right scope for the contractor.

## Before you start

```bash
./start.sh m08
./start.sh status
```

The launcher finds the container runtime for you. You do not need to choose one.

The state adds an `identity` service. It is a local user database: `/etc/passwd`,
`/etc/group`, a reports share, and a small `sudo` rule. In a production estate the same
data would live in a directory service such as LDAP or another central identity store. The
questions are the same: who is this, and what may they do?

## Part 1: Observe the failure

The reporting service runs as the `svc-report` account. Run its read as that account:

```bash
./start.sh exec --user svc-report identity cat /reports/quarterly.txt
```

1. What error do you see?
2. Is this an authentication failure or an authorisation failure?
3. What evidence would tell you which one it is?

**Predict before you act:** the account exists and the file exists. What could still deny
the read?

## Part 2: Read the identity data

Inspect the account and the group:

```bash
./start.sh exec identity getent passwd svc-report
./start.sh exec identity getent group reporting
./start.sh exec --user svc-report identity id
```

Compare with two accounts that work and one that should not:

```bash
./start.sh exec --user bob identity id
./start.sh exec --user contractor identity id
./start.sh exec --user bob identity cat /reports/quarterly.txt
./start.sh exec --user contractor identity cat /reports/quarterly.txt
```

Inspect the share:

```bash
./start.sh exec identity ls -ld /reports
./start.sh exec identity ls -l /reports
```

Answer these:

1. What are the UID, primary GID and supplementary groups for `svc-report`?
2. Which group owns `/reports`, and which group owns `quarterly.txt`?
3. Which permission bit lets a group member read the file?
4. Why can `bob` read the file and `contractor` cannot?
5. What is the difference between the primary group and a supplementary group?

## Part 3: Fix the service account

```bash
./start.sh fix-m08
./start.sh exec --user svc-report identity cat /reports/quarterly.txt
./start.sh exec identity getent group reporting
```

You should see the report and `svc-report` back in the `reporting` group.

1. What exactly changed?
2. Why is adding the account to the group safer than `chmod 777 /reports`?
3. What would you check after a restart to prove the fix is persistent?

## Part 4: Contractor access

The contractor is approved to read the quarterly report, not the board pack. Start by
confirming the current denial:

```bash
./start.sh exec --user contractor identity cat /reports/quarterly.txt
./start.sh exec --user contractor identity cat /reports/board-pack.txt
```

Now grant read access by group:

```bash
./start.sh exec identity addgroup contractor reporting
./start.sh exec --user contractor identity cat /reports/quarterly.txt
./start.sh exec --user contractor identity cat /reports/board-pack.txt
```

1. Which file can the contractor read, and which is still denied?
2. Why is the board pack still protected even though the contractor is in `reporting`?
3. Is adding the contractor to `reporting` the least-privilege answer? What else could
   you do?
4. How would you remove the access when the contract ends?
5. What should be logged so the access is auditable?

Remove the contractor again when you have finished:

```bash
./start.sh exec identity delgroup contractor reporting
```

## Part 5: Privilege escalation

The `alice` account has a narrow `sudo` rule. Test what it can and cannot do:

```bash
./start.sh exec --user alice identity sudo -n id
./start.sh exec --user alice identity sudo -n cat /reports/quarterly.txt
```

Inspect the rule:

```bash
./start.sh exec identity cat /etc/sudoers.d/ops
```

1. Which command may `alice` run as root?
2. What happens when she tries a different command?
3. Why is a narrow rule better than adding `alice` to the `wheel` group?
4. What would you log to detect misuse of this rule?

## Part 6: Put it back

Return the reporting service to the broken state:

```bash
./start.sh break-m08
./start.sh exec --user svc-report identity cat /reports/quarterly.txt
```

The failure returns. This is the reset point for the exercise. If you added the
contractor to `reporting`, remove them again.

## The directory concept

The identity service is a local database. A directory service moves the same records to a
server so that many hosts and applications share one answer:

| Local file | Directory equivalent |
|---|---|
| `/etc/passwd` | User object with attributes |
| `/etc/group` | Group object with members |
| `getent passwd alice` | A directory search for the user |
| `id` | The groups resolved for the authenticated identity |
| `sudoers` | A policy rule attached to a user or group |

You do not need an LDAP server to learn the model. You do need to know that the local
files and the directory answer the same two questions: who is this, and what may they do?

## Evidence

- The `Permission denied` error and the `id` output for `svc-report`.
- `getent group reporting` before and after the fix.
- `ls -ld /reports` and `ls -l /reports`.
- The exact fix command, and why it is the smallest safe change.
- The contractor test: which file is readable and which is denied.
- The result of both `sudo` tests.
- One place where AI was wrong, vague or over-confident about identity or permissions.

## AI conversation prompts

Use these as starters, then check the answer against the container:

- "What is the difference between authentication and authorisation? Give an example from
  a Linux host."
- "A service account exists and a file exists, but the service gets permission denied.
  What are the possible causes?"
- "Why is adding a user to a group better than making a directory world-writable?"
- "What is the least-privilege way to give a contractor read access to one report?"

Check whether the answer separates identity from permission. If it says "just chmod 777",
ask what that does to every other account on the host, then record the correction.

## Clean up

```bash
./start.sh down
```

A reset returns the identity service to its good state:

```bash
./start.sh reset m08
```
