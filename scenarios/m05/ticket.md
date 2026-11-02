# Ticket: the portal name resolves to the wrong address

**From:** David Wilson, Cloud Infrastructure Architect
**Priority:** high
**Service:** customer web portal

The portal name resolves, but it resolves to the wrong address. Customers who use the name
fail; customers who use the address directly reach the page.

## What we know

- The web tier is running at `172.28.0.10`.
- The estate has an internal DNS server at `172.28.0.53`.
- The tools container uses the container runtime's embedded DNS.
- The record was changed recently.

## What we need

1. Show which resolver answered and what it returned.
2. Prove the wrong address is the cause.
3. Fix it with the smallest safe change.
4. Recommend how DNS changes should be owned and checked.

## Evidence we expect

- The `dig` output before and after.
- The `curl` error with the wrong address.
- The record and the file that holds it.
- A recommendation with an owner and a check.
