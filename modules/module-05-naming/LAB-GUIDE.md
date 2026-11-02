# Module 05: Addressing and naming

**Ticket:** the portal name resolves to the wrong address.

**Goal:** diagnose a name-resolution failure, fix the record, and explain which resolver
answered and why.

## Before you start

```bash
./start.sh m05
./start.sh status
./start.sh console
```

Inside the tools container:

```bash
dig @dns portal.estate.local +short
dig @dns web +short
getent hosts portal.estate.local
cat /etc/resolv.conf
```

The estate DNS server is the `dns` container at `172.28.0.53`. The tools container still uses
the container runtime's embedded DNS, not the estate DNS.

## Part 1: Two resolvers

1. What does `dig @dns portal.estate.local` return?
2. What does `dig @dns web` return?
3. What does `getent hosts portal.estate.local` return, and why?
4. Which nameserver is in `/etc/resolv.conf`?
5. Test the web tier by name without changing the resolver:

```bash
curl -fsS --resolve portal.estate.local:80:172.28.0.10 http://portal.estate.local/ | head
```

**Predict before you act:** if the DNS record points at the wrong address, what will `dig`
show and what will `curl` do?

## Part 2: Break it

From the host terminal, not inside the tools shell:

```bash
./start.sh break-m05
```

Back in the tools container:

```bash
dig @dns portal.estate.local +short
curl --resolve portal.estate.local:80:172.28.0.99 http://portal.estate.local/
```

1. What address does `dig` return now?
2. What does `curl` report?
3. Which log or command proves the DNS answer is wrong?
4. What is the smallest safe change?

## Part 3: Fix it

From the host terminal:

```bash
./start.sh fix-m05
```

Back in the tools container:

```bash
dig @dns portal.estate.local +short
curl -fsS --resolve portal.estate.local:80:172.28.0.10 http://portal.estate.local/ | head
```

Explain:

1. Which file holds the record?
2. Why does the tools container still resolve `portal.estate.local` only with `--resolve`?
3. What would you change to make the tools container use the estate DNS for every lookup?
4. What would you monitor so a wrong record is caught before a customer reports it?

## Part 4: Evidence

Add these to your conversation log or portfolio:

- The `dig` output before, during and after the fault.
- The `curl` error with the wrong address.
- The record and the file that holds it.
- Your explanation of the two resolvers.
- Your recommendation for DNS ownership and change control.
- One place where AI was wrong, vague or over-confident.

## AI prompts

- "A client uses Docker's embedded DNS and a separate internal DNS server exists. Which one
  answers `getent hosts` and which one answers `dig @dns`?"
- "A DNS A record points at the wrong address. What are the smallest safe changes, and what
  are the risks of each?"
- "Where does this explanation overreach? What does it leave out about caching, TTL and
  search domains?"

## Clean up

```bash
exit
./start.sh fix-m05
./start.sh down
```
