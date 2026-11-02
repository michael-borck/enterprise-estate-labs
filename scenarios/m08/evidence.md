# Evidence prompts

Capture the following for your portfolio:

- The `getent group reporting` output before and after the fix.
- The `id` output for `svc-report`, `bob` and `contractor`.
- The `ls -ld /reports` and `ls -l /reports` output.
- The exact `Permission denied` error.
- The command you used to fix the service account, and why it is the smallest safe change.
- The result of the `sudo -n id` test as `alice`, and the result of the `sudo -n cat` test.
- Your recommendation for the contractor: which group, which permission, and how the
  access is removed when the contract ends.
- One place where AI was wrong, vague or over-confident about identity or permissions.
