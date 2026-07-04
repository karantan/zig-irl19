# SiteProbe API contract

Base URL: `http://127.0.0.1:8080`

All JSON responses include:

```http
Content-Type: application/json
Access-Control-Allow-Origin: *
```

The browser UI in `web/index.html` relies on CORS being enabled.

---

## GET /health

Liveness check.

**Response 200**

```json
{"status":"ok"}
```

**Example**

```bash
curl -s http://127.0.0.1:8080/health
```

---

## POST /probe

Probe a remote URL with an HTTP GET. Returns status code and elapsed time.

**Request**

```http
POST /probe HTTP/1.1
Content-Type: application/json

{"url":"https://example.com"}
```

**Response 200** — probe succeeded (any HTTP status from target is OK)

```json
{
  "url": "https://example.com",
  "status": 200,
  "elapsed_ms": 42,
  "ok": true,
  "content_type": null
}
```

| Field | Type | Meaning |
|-------|------|---------|
| `url` | string | Echo of requested URL |
| `status` | number | HTTP status from target |
| `elapsed_ms` | number | Round-trip time in milliseconds |
| `ok` | bool | `true` if status is 2xx or 3xx |
| `content_type` | string \| null | Optional bonus (Pair D) |

**Response 400** — bad input

```json
{"error":"invalid url"}
```

Also return 400 for malformed JSON:

```json
{"error":"invalid json"}
```

**Response 502** — could not reach URL

```json
{"error":"request failed"}
```

**Examples**

```bash
# Success
curl -s -X POST http://127.0.0.1:8080/probe \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com"}'

# Invalid URL
curl -s -X POST http://127.0.0.1:8080/probe \
  -H 'Content-Type: application/json' \
  -d '{"url":"not-a-url"}'

# Invalid JSON
curl -s -X POST http://127.0.0.1:8080/probe \
  -H 'Content-Type: application/json' \
  -d 'not json'
```

---

## Out of scope (day 1)

- Authentication
- TLS termination on SiteProbe itself
- Database / persistence
- Concurrent connection handling (sequential is fine)
- HTML parsing libraries (optional `title` bonus via naive string search)
