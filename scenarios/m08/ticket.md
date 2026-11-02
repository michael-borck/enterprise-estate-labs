# Ticket: the reporting service cannot read the finance report

**From:** Louise Tan, Finance Systems Manager
**Priority:** high
**Service:** quarterly reporting

The quarterly reporting service stopped reading the finance report after the identity
service was rebuilt. The service account exists and the report exists, but every read
fails with `Permission denied`.

At the same time, we have approved a contractor to read the same report. Read only. The
contractor must not be able to change it, and must not see the rest of the finance share.

I need the reporting service working again, and a recommendation for the contractor that
does not give either account more access than it needs.
