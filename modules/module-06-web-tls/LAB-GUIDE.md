# Module 06: Protocols and the web tier

**Ticket:** customers see a certificate warning when they reach the CloudCore site.

**Goal:** trace a request from the browser through the TLS proxy to the web tier, and
explain where TLS ends and where the request is re-originated.

## Before you start

```bash
make m06
make status
```

Open <https://localhost:8443>. The certificate is self-signed, so the browser warning is
expected. Do not click through blindly. Inspect the certificate first.

## Part 1: Read the certificate

In the browser, open the certificate details. Record:

1. Who issued it?
2. Who is it issued to?
3. When does it expire?
4. Why does the browser not trust it?

From the host:

```bash
openssl s_client -connect localhost:8443 -servername localhost </dev/null
```

Look at the certificate chain and the verification result.

## Part 2: Trace the request

1. Open <http://localhost:8080>. What happens?
2. Open <https://localhost:8443>. Which service answered?
3. From the tools container, run `curl -k https://proxy/`. What do you get?
4. From the tools container, run `curl http://web/`. What do you get?
5. Read the Caddy and nginx logs:

```bash
make logs
```

**Predict before you act:** where does TLS terminate? Which service holds the
certificate? Which service sees the plain HTTP request?

## Part 3: Break it

Edit `estate/proxy/Caddyfile` and change the upstream from `web:80` to `web:81`.

```bash
docker compose --profile m03 --profile m06 restart proxy
curl -k https://localhost:8443/
```

1. What status code do you get?
2. Which log shows the failure?
3. Restore the upstream to `web:80` and restart the proxy.

## Part 4: Evidence

- The certificate details before you clicked through.
- A one-line request path: browser to proxy to web.
- The log line that proves which service handled the request.
- Your explanation of why the warning appears, and why `curl -k` is not a fix.
- One place where AI was wrong, vague or over-confident.

## AI prompts

- "Explain the difference between TLS termination at a reverse proxy and TLS passthrough."
- "A browser shows a certificate warning for a self-signed certificate. What exactly is
  the browser checking, and what would make the warning disappear?"
- "Where does this explanation overreach? What does it leave out about trust stores and
  certificate authorities?"

## Clean up

```bash
make down
```
