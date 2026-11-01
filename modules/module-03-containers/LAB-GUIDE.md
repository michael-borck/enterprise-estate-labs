# Module 03: Processes, memory and containers

**Ticket:** the CloudCore site is slow under load.

**Goal:** bring up the first estate state, observe a container under load, and explain
what the resource limits are doing.

## Before you start

```bash
./start.sh m03
./start.sh status
./start.sh console
```

The launcher finds the container runtime for you. You do not need to choose one.

Inside the tools container:

```bash
curl http://web/
```

You should see the CloudCore estate page.

## Part 1: What is running

1. From the host, run `./start.sh status`. Which containers are running?
2. From the tools container, run `ps aux`. How many processes can you see?
3. Run `curl -s http://web/ | head`. What did the web tier return?
4. Open `compose.yml`. Find the `deploy.resources.limits` for `web` and `db`.

**Predict before you act:** what do you think happens to the web container if it is
limited to 0.25 CPU and you send it a steady stream of requests?

## Part 2: Load and observe

From the tools container, start a simple load loop:

```bash
while true; do curl -s http://web/ >/dev/null; done
```

From the host, in a second terminal:

```bash
./start.sh stats
```

Watch the `CPU %` and `MEM USAGE / LIMIT` columns for `web` and `db`.

1. Which container is doing the work?
2. Is the CPU limit being reached?
3. What happens to response time as the loop continues?

Stop the loop with `Ctrl-C`.

## Part 3: Change the limit

From the host, lower the web container's CPU limit:

```bash
./start.sh limit web 0.05
```

You do not need the container name. The launcher finds it.

Run the load loop again and observe `./start.sh stats`. Then restore the limit:

```bash
./start.sh limit web 0.25
```

**Record:** what changed, what you expected, and what actually happened.

## Part 4: Evidence

Add these to your conversation log or portfolio:

- Your prediction before the first load test.
- The `./start.sh stats` output before, during and after the load.
- One sentence explaining why the container is limited rather than the host.
- One place where AI was wrong, vague or over-confident.

## AI prompts

Use these as conversation starters, then challenge the answer:

- "Explain what a container CPU limit does to a process inside the container, and what it
  does not do to the host."
- "A web container is limited to 0.25 CPU. What will a client observe under sustained
  load, and what will the container itself observe?"
- "Where does this explanation overreach? What does it leave out about memory pressure
  and the host kernel?"

## Clean up

```bash
./start.sh down
```
