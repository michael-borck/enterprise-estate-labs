# Module 04: Networking models

**Ticket:** customers report that the portal times out, but the service is running.

**Goal:** trace a request from the tools container to the web tier, capture it, and explain
the address, port and flags at each step.

This module uses the existing `m03` state. There is no `m04` profile.

## Before you start

```bash
./start.sh m03
./start.sh status
./start.sh console
```

Inside the tools container:

```bash
ip -brief addr
ip route
getent hosts web
curl -sv http://web/ 2>&1 | head -20
```

## Part 1: Interface, route and name

1. Which interface has an address, and what is it?
2. What is the default route?
3. What address does `web` resolve to?
4. Which port did curl use, and which status code came back?

## Part 2: Capture the request

Capture the traffic while you make one request:

```bash
timeout 8 tcpdump -i eth0 -nn -c 20 &
sleep 1
curl -s http://web/ >/dev/null
wait
```

Find the ARP request and reply, if they appear. Then find the `SYN`, `SYN-ACK` and `ACK`.
Then find the HTTP request and the response.

Capture the HTTP text:

```bash
timeout 8 tcpdump -i eth0 -nn -A -c 12 port 80 &
sleep 1
curl -s http://web/ >/dev/null
wait
```

Find the `GET / HTTP/1.1` line and the `HTTP/1.1 200 OK` line.

**Predict before you act:** if the web port is wrong, will the client see a refusal or a
timeout?

## Part 3: Break the port

Try a port with no listener:

```bash
curl -v http://web:81
```

Capture it:

```bash
timeout 5 tcpdump -i eth0 -nn -c 10 port 81 &
sleep 1
curl -v http://web:81
wait
```

1. What error did curl report?
2. What did the capture show? Look for a reset.
3. How is a refusal different from a timeout?
4. What would you check first if a customer reported a timeout?

## Part 4: Evidence

Add these to your conversation log or portfolio:

- The interface, route and `web` address.
- The capture with the handshake, the request and the response.
- The refusal on port 81 and the reset.
- Your explanation of the difference between a refusal and a timeout.
- The network check you would add, with the owner and the alert.

## AI prompts

Use these as conversation starters, then challenge the answer:

- "Explain the difference between a frame, a packet and a segment."
- "A client connects to a web server on port 80. What will `tcpdump` show in the first three
  packets?"
- "A connection is refused. What is the difference between a refusal and a timeout?"
- "Where does this explanation overreach? What does it leave out about ARP, routing and
  middleboxes?"

If the AI says a switch routes by IP, ask it which layer a switch uses and check it.

## Clean up

```bash
exit
./start.sh down
```

The volumes are kept. `./start.sh reset m03` removes them.
