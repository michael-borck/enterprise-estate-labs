# Module 11: Security, privacy and incident response

**Ticket:** an admin configuration page exposed the database password, and the security log
shows someone used it.

**Goal:** triage the log, reproduce the exposure, contain it, rotate the secret, verify the
fix, and write an incident record with the scope, the decisions and the prevention work.

## Before you start

```bash
./start.sh m11
./start.sh status
```

The launcher finds the container runtime for you. You do not need to choose one.

The state adds a `logs` container with a read-only copy of `estate/security/`. The security
log is the evidence. The web tier also serves an `admin` directory. The database secret is
in `estate/security/db_password`, and the same value is exposed in the web page.

## Part 1: Read the security log

```bash
./start.sh exec logs cat /logs/security.log
./start.sh exec logs grep '203.0.113.45' /logs/security.log
./start.sh exec logs awk '{print $3, $4}' /logs/security.log | sort | uniq -c
```

Build a timeline. For each event, record:

1. The timestamp.
2. The source address.
3. The action and the result.
4. Whether it is a failed attempt or a success.

Answer these:

1. When did the source first appear?
2. How many failed logins came from it?
3. Which requests succeeded?
4. What did the source do after the successful reads?
5. What does the log not tell you?
6. Is the source address personal data? What does that change about how you store the log?

Do not delete or edit the log. It is evidence.

## Part 2: Reproduce the exposure

```bash
./start.sh exec tools curl -fsS http://web/admin/config.txt
./start.sh exec logs ls -l /logs/db_password
./start.sh exec logs cat /logs/db_password
```

1. What exactly is exposed?
2. Which account does the database password belong to?
3. Is the exposed value still the live credential, or a demo value?
4. Who could reach the page: anyone on the estate network, or anyone on the internet?
5. What is the worst thing an attacker could do with the exposed values?

**Predict before you act:** which change closes the exposure without deleting the evidence
or breaking the service?

## Part 3: Contain and eradicate

```bash
./start.sh fix-m11
./start.sh check-m11
./start.sh exec tools curl -i http://web/admin/config.txt
./start.sh exec logs ls -l /logs/db_password
./start.sh exec logs cat /logs/db_password
```

1. What did the fix change, in order?
2. Why was the web page removed before the secret was rotated?
3. Why is removing the page not enough on its own?
4. What else must be rotated outside this container? Name the database credential, the
   admin token and any session that used them.
5. How would you prove the old value no longer works?
6. Did the portal stay available during the fix?

`check-m11` verifies three things: the page is no longer reachable, the secret file is mode
`600`, and the value is no longer the demo value. It also confirms the incident source is
still in the log.

## Part 4: Recover and harden

1. What monitoring would catch this sooner: an alert on 404s, a secret scanner, a web
   application firewall, or an access review?
2. What would you add to the web tier so an admin page requires authentication?
3. What would you add to the secret store so the value is not a file on disk?
4. What would you log, and what would you deliberately not log, to protect privacy?
5. Who owns the restore test and the incident review?

## Part 5: Write the incident record

Use the template in `scenarios/m11/incident-template.md`. It must cover:

1. Detection: who or what reported it, and when.
2. Scope: what the source did, what it may have reached, and what is still unknown.
3. Containment: what you changed, in order, and why.
4. Eradication and recovery: what you removed or rotated, and how you verified it.
5. Notification: who needs to know, and what the legal or contractual obligation is.
6. Lessons learned: which control failed, and what changes next.
7. Evidence retained: where the log, screenshots and commands are stored.

The incident record is a business document. Write it for someone who was not in the room.

## Part 6: Put it back

```bash
./start.sh break-m11
./start.sh exec tools curl -fsS http://web/admin/config.txt
```

The exposure returns. This is the reset point for the exercise. The security log remains.

## Evidence

- The exposed `config.txt` content and the URL that served it.
- The log lines that show the failed logins and the successful reads.
- A timeline with timestamps, source, action and result.
- The secret file's mode and content before and after the fix.
- The `check-m11` output before and after the fix.
- The exact containment steps, in order, and why.
- What you rotated, and what still needs rotation outside the container.
- The incident record.
- One place where AI was wrong, vague or over-confident about the incident.

## AI conversation prompts

Use these as starters, then check the answer against the estate:

- "What are the phases of incident response, and what belongs in each one?"
- "A web page exposes a database password. What is the containment order, and why?"
- "What is the difference between removing a secret and rotating it?"
- "What personal data is in a security log, and how does retention apply?"
- "Where does this explanation overreach? What does it assume about the log and the
  credential?"

Check whether the answer separates containment from eradication and eradication from
recovery. If it says "delete the page and you are done", ask what happens to the credential
that was already copied.

## Clean up

```bash
./start.sh down
```

A reset returns the state to a clean Module 11:

```bash
./start.sh reset m11
```
