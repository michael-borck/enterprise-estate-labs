# Evidence: Module 05

Record these in your portfolio or conversation log.

| Item | What to capture |
|---|---|
| Resolver | `cat /etc/resolv.conf`; the nameserver |
| Record | `dig @dns portal.estate.local +short` before and after |
| Fault | The wrong address and the `curl` error |
| Fix | The file changed and the command used |
| Judgement | DNS ownership, change control and the check |

## Challenge prompt

Ask an AI assistant which resolver answers `getent hosts` and which answers `dig @dns`. Then
check the answer against `/etc/resolv.conf` and the `dns` container. Record what it got wrong
or left out.
