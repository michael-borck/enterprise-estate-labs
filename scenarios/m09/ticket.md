# Ticket: the reporting service cannot write to the finance share

**From:** Finance Systems, CloudCore Networks
**Priority:** high
**Service:** reporting

The reporting service has stopped writing its daily output to the finance share. The
service is running. The share exists. The error says permission denied.

## What we know

- The share is a Docker named volume.
- The reporting service runs as a non-root user.
- The share was created by Docker and has not been changed since.
- Other services read from the share but do not write to it.

## What we need

1. Diagnose the permission failure.
2. Fix it with the smallest safe change.
3. Explain why a world-writable share is not acceptable.
4. Say what you would monitor so this is caught earlier next time.

## Evidence we expect

- The error and the ownership of the share before the fix.
- The exact fix and why it is the smallest safe change.
- The file after the fix, with correct ownership.
- A short risk note for the finance manager.
