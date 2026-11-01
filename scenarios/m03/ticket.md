# Ticket: the site is slow under load

**From:** Operations, CloudCore Networks
**Priority:** medium
**Service:** customer web portal

Customers report that the portal becomes slow when several people use it at once. The
page loads, so this is not an outage. The service is running, but it is not keeping up.

## What we know

- The web tier is a container with a CPU and memory limit.
- The database is in its own container.
- Nothing has changed in the application recently.

## What we need

1. Confirm which container is doing the work under load.
2. Show whether the limit is being reached.
3. Recommend a change and explain the trade-off. A larger limit costs more. Removing the
   limit risks the host. Doing nothing risks the customer.

## Evidence we expect

- A prediction before the load test.
- Resource usage before, during and after the load.
- The command you used and why.
- A short recommendation for the operations manager.
