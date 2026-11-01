CREATE TABLE IF NOT EXISTS tickets (
    id serial PRIMARY KEY,
    opened_at timestamptz NOT NULL DEFAULT now(),
    summary text NOT NULL
);

INSERT INTO tickets (summary)
VALUES ('customers cannot reach the site')
ON CONFLICT DO NOTHING;
