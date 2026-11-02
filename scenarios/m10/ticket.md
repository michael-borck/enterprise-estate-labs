# Ticket: the restore test is empty

**From:** Louise Tan, Finance Systems Manager
**Priority:** high
**Service:** quarterly reporting and customer tickets

The nightly backup reports success every night. This morning we ran a restore test and the
restored database has no customer tickets. The schema is there, the tables are there, and
the rows are gone.

I need three things:

1. The data back in a usable restore.
2. An explanation of why the backup reported success while the restore was empty.
3. A recommendation for how we store and test backups, including what it costs and how long
   a recovery would take.
