# Ticket: the admin config is public

**From:** Sophia Martines, Chief Information Security Officer
**Priority:** critical
**Service:** customer portal and the estate secret store

A customer sent us a screenshot of `http://portal.estate.local/admin/config.txt`. The page
shows the database password and an admin token. The security log shows repeated failed
logins for `admin` and two successful requests to that path from the same address,
`203.0.113.45`.

I need four things:

1. The exposure closed.
2. The credential rotated, with evidence that the old value is no longer in use.
3. The scope of the incident: what the source did, in order, and what else it may have
   reached.
4. An incident record with the decisions, the notifications and the prevention work.

Do not delete the log. It is evidence.
