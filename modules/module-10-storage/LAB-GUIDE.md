# Module 10: Storage, virtualisation and cloud

**Ticket:** the nightly backup reports success, but the restored database has no customer
tickets.

**Goal:** prove whether a backup is usable, find why a successful job produced an empty
restore, fix it, and choose a backup and storage design with a recovery time you can defend.

## Before you start

```bash
./start.sh m10
./start.sh status
```

The launcher finds the container runtime for you. You do not need to choose one.

The state adds a `backup` service. It has `pg_dump` and `psql`, a read-only copy of the
backup scripts, and a `backup-data` volume. The estate database holds three customer
tickets. The backup writes to the volume, not to the container's own file system, so the
file survives a container restart.

## Part 1: Take a backup and inspect it

Run the backup:

```bash
./start.sh exec backup sh /backup/backup.sh
```

Check the job's own record:

```bash
./start.sh exec backup cat /backups/backup.log
./start.sh exec backup ls -l /backups
```

Now inspect the backup file itself:

```bash
./start.sh exec backup head -n 30 /backups/estate.sql
./start.sh exec backup sh -c "grep -c '^COPY' /backups/estate.sql || true"
./start.sh exec backup wc -l /backups/estate.sql
```

1. Does the log say the backup succeeded?
2. Does the file contain the table definitions?
3. Does the file contain the data rows?
4. What does the `COPY` count tell you?

**Predict before you act:** if you restore this file, how many tickets will the restored
database have?

## Part 2: Restore and compare

```bash
./start.sh exec backup sh /backup/restore.sh
```

1. How many tickets are in the live database?
2. How many tickets are in `estate_restore`?
3. Did the restore report an error, or did it succeed with missing data?

Inspect the restored schema:

```bash
./start.sh exec backup psql -h db -U estate -d estate_restore -c '\dt'
./start.sh exec backup psql -h db -U estate -d estate_restore -c 'SELECT count(*) FROM tickets;'
```

A backup that restores a table with no rows is not a backup of the data. It is a backup of
the shape of the data.

## Part 3: Diagnose

Read the backup command:

```bash
./start.sh exec backup cat /backup/backup.sh
```

1. Which option changes what `pg_dump` writes?
2. Why did the job still exit successfully?
3. Why did the log still say "backup complete"?
4. What would a restore test have caught that the job log did not?

The job reports the process exit code, not the usefulness of the output. A successful
process can produce an unusable backup.

## Part 4: Fix and verify

```bash
./start.sh fix-m10
./start.sh exec backup sh /backup/backup.sh
./start.sh exec backup sh /backup/restore.sh
```

1. How many tickets are in the live database now?
2. How many tickets are in `estate_restore`?
3. Which evidence proves the backup is usable, and which evidence only proves the job ran?
4. Why is a restore into a separate database safer than restoring over the live one?

Run the restore a second time. It should give the same result. A restore that works once is
not yet a repeatable procedure.

## Part 5: Recovery objectives and storage design

Answer these for the CloudCore ticket database:

1. What is a sensible recovery point objective (RPO)? How much data can the business lose?
2. What is a sensible recovery time objective (RTO)? How long can the service be down?
3. Where should the backup be stored? Consider the same host, a second host, object storage
   and a managed database backup.
4. What would you encrypt, and where would the key live?
5. How often would you run a restore test, and who owns the result?
6. What does each option cost in storage, transfer and staff time?

Use this table to structure the decision:

| Option | RPO | RTO | Cost | Main risk |
|---|---|---|---|---|
| Local volume snapshot | | | | |
| Offsite object storage | | | | |
| Managed database backup | | | | |

A backup on the same host protects against a deleted table. It does not protect against the
host, the disk or the account being lost. Say which failure each option covers.

## Part 6: Put it back

```bash
./start.sh break-m10
./start.sh exec backup sh /backup/backup.sh
./start.sh exec backup sh /backup/restore.sh
```

The restore is empty again. This is the reset point for the exercise.

## Evidence

- The backup log line and the file listing.
- The `COPY` count and the head of the backup file.
- The restore output before and after the fix.
- The backup command before and after the fix.
- Your RPO and RTO, with a reason.
- Your storage recommendation, with cost, risk and the failure it covers.
- One place where AI was wrong, vague or over-confident about backup or restore.

## AI conversation prompts

Use these as starters, then check the answer against the container:

- "What is the difference between a backup, a snapshot and replication?"
- "A backup job exits successfully but the restore has no rows. What could cause that?"
- "What are RPO and RTO, and how do they change the backup design?"
- "What does the 3-2-1 rule mean, and what does it not protect against?"
- "Where does this explanation overreach? What does it assume about the storage and the
  restore test?"

Check whether the answer separates "the job ran" from "the data can be restored". If it
treats a successful exit code as proof, correct it and record the correction.

## Clean up

```bash
./start.sh down
```

A reset returns the state to a clean Module 10:

```bash
./start.sh reset m10
```
