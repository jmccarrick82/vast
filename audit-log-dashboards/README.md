# VAST Audit Log Dashboards for Grafana

Pre-built Grafana dashboards that query VAST Data audit logs via Trino. No additional data pipelines or storage required — queries go directly from Grafana → Trino → VAST audit log tables.

![Grafana 10.2](https://img.shields.io/badge/Grafana-10.2-orange)
![Trino](https://img.shields.io/badge/Trino-VAST%20Connector-blue)

## Dashboards

| Dashboard | Description |
|-----------|-------------|
| **Overview** | High-level audit activity summary — stats, top users, top directories, destructive ops, cross-protocol access |
| **File Lineage** | Track every operation on a file over time — reads, writes, renames, moves, deletes. Supports wildcard search with `*` |
| **Hot Files** | Top N most accessed files ranked by operation count, configurable (10/25/50/100) |
| **User IO Breakdown** | Per-user IO analysis — ops/sec over time, data volume, protocol usage, top files and directories |

## Prerequisites

- **VAST Data cluster** with audit logging enabled
- **Trino** with the [VAST connector](https://support.vastdata.com/s/topic/0TOPn000000kHPOOA2/trino) configured
- **Docker** and **Docker Compose**

The dashboards query this table (VAST's default audit log location):
```
<catalog>."vast-audit-log-bucket/vast_audit_log_schema".vast_audit_log_table
```

## Quick Start

```bash
git clone https://github.com/jmccarrick82/vast.git
cd vast/audit-log-dashboards

# Configure your Trino connection
cp .env.example .env
# Edit .env — set TRINO_URL to your Trino endpoint

# Start
docker compose up -d
```

Open **http://localhost:3000** — no login required.

## Configuration

All configuration is done via environment variables in the `.env` file:

| Variable | Default | Description |
|----------|---------|-------------|
| `TRINO_URL` | `http://host.docker.internal:8080` | Trino endpoint URL |
| `TRINO_CATALOG` | `vast` | Trino catalog name for your VAST cluster |
| `TRINO_USER` | `grafana` | Trino username |
| `TRINO_PASSWORD` | *(empty)* | Trino password (if auth is enabled) |
| `GRAFANA_PORT` | `3000` | Port Grafana listens on |

### Examples

**Trino on the same host:**
```env
TRINO_URL=http://host.docker.internal:8080
```

**Trino on a remote host:**
```env
TRINO_URL=http://172.200.204.31:8080
```

**Multiple VAST clusters:**

If your Trino instance has multiple VAST catalogs (e.g., `vast`, `vast_prod`, `vast_dr`), they will automatically appear in the catalog dropdown on each dashboard. Just set `TRINO_CATALOG` to your preferred default.

## Changing Configuration

After editing `.env`, recreate the container to pick up the changes:

```bash
docker compose down
docker compose up -d
```

> **Note:** `docker restart` won't work — the `.env` file is only read when the container is created.

## Updating Dashboards

Grafana caches provisioned dashboards in its database volume. When pulling new dashboard versions:

```bash
docker compose down -v          # Remove volume to clear cache
docker compose build --no-cache # Rebuild image with new dashboards
docker compose up -d
```

## Dashboard Details

### Template Variables

All dashboards include these dropdowns/filters at the top:

| Variable | Type | Description |
|----------|------|-------------|
| `trino_catalog` | Dropdown | Auto-populated from `SHOW CATALOGS` — switch between VAST clusters |
| `dir_prefix` | Text | Filter by path prefix (e.g., `/data/trading`) |
| `user_prefix` | Text | Filter by username prefix |
| `action_prefix` | Text | Filter by operation type (e.g., `WRITE`, `DELETE`) |

The **File Lineage** dashboard has a `file_search` field that supports wildcards:
- `/data/reports` — prefix match
- `*/backup*` — contains match
- `*.csv` — extension match

### VAST Audit Log Columns Used

| Column | Description |
|--------|-------------|
| `path.path` | Full file path |
| `rpc_type` | Operation (READ, WRITE, CREATE, DELETE, RENAME, LOOKUP, etc.) |
| `protocol` | Access protocol (NFSv3, NFSv4, S3, NDB) |
| `time` | Event timestamp |
| `login_name` / `uid` | User identity |
| `num_bytes` | Bytes transferred |
| `client_ip` | Client IP address |
| `rename_path` | Original path before a rename/move operation |
| `cluster_name` | VAST cluster name |

## Troubleshooting

### No data showing
- Expand the Grafana time range — try "Last 7 days" or wider
- Verify Trino is reachable: `curl http://<trino-host>:8080/v1/info`
- Check container logs: `docker logs grafana-vast-audit`

### "getTableHandle() is not implemented" errors
- This is a VAST Trino connector limitation with certain SQL patterns
- The dashboards are designed to avoid these, but if you customize queries, use `column IN ('X', 'Y')` instead of `contains(ARRAY['X', 'Y'], column)`

### Dashboard changes not appearing
```bash
docker compose down -v && docker compose build --no-cache && docker compose up -d
```

## License

[MIT](LICENSE)
