# Ticket: the portal times out for some customers

**From:** Samantha Wong, Customer Support Lead
**Priority:** high
**Service:** customer web portal

Some customers say the portal times out. Others reach it without a problem. The service is
running.

## What we know

- The web tier is a container on the estate network.
- The tools container can reach the web tier by name.
- The host shell is not on the estate network.
- Nothing has changed in the application recently.

## What we need

1. Capture one request from the tools container to the web tier.
2. Show the handshake, the ports and the HTTP request.
3. Explain the difference between a refusal and a timeout.
4. Recommend a check that would catch the problem before a customer does.

## Evidence we expect

- The interface, route and name resolution.
- A packet capture of one request.
- The refusal on a closed port.
- A recommendation with an owner and an alert.
