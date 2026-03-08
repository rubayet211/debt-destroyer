create table if not exists attestation_challenges (
  challenge_id text primary key,
  install_id text not null,
  nonce text not null,
  expires_at timestamptz not null,
  consumed_at timestamptz null,
  created_at timestamptz not null default now()
);

create table if not exists install_sessions (
  install_id text primary key,
  attestation_status text not null,
  blocked_until timestamptz null,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists refresh_tokens (
  token_id text primary key,
  install_id text not null references install_sessions(install_id) on delete cascade,
  token_hash text not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz null,
  created_at timestamptz not null default now()
);

create table if not exists usage_counters (
  install_id text not null references install_sessions(install_id) on delete cascade,
  month_key text not null,
  cloud_extractions integer not null default 0,
  reserved_extractions integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (install_id, month_key)
);

alter table usage_counters
  add column if not exists reserved_extractions integer not null default 0;

create table if not exists quota_reservations (
  reservation_id text primary key,
  install_id text not null references install_sessions(install_id) on delete cascade,
  month_key text not null,
  status text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  committed_at timestamptz null,
  released_at timestamptz null
);

create index if not exists quota_reservations_active_idx
  on quota_reservations (install_id, month_key, status, expires_at);

create table if not exists premium_entitlements (
  install_id text primary key references install_sessions(install_id) on delete cascade,
  is_premium boolean not null default false,
  features jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists extraction_requests (
  request_id text primary key,
  install_id text not null references install_sessions(install_id) on delete cascade,
  classification text not null,
  provider text not null,
  model text not null,
  status text not null,
  latency_ms integer not null,
  ocr_hash text not null,
  ocr_preview text null,
  warnings jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists audit_events (
  event_id text primary key,
  install_id text null,
  request_id text null,
  event_type text not null,
  payload jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists rate_limit_events (
  event_id text primary key,
  install_id text null,
  ip_address text null,
  key text not null,
  limit_value integer not null,
  remaining integer not null,
  reset_at timestamptz not null,
  created_at timestamptz not null default now()
);
