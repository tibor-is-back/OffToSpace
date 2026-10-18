# SpaceX Mock API

Local stand-in for the retired `https://api.spacexdata.com` v4 launches and rockets endpoints. Responses follow the original SpaceX API shapes so the iOS assignment app can talk to this server with `URLSession`.

## Start

```bash
cd mock-api
npm install
npm start
```

The server listens on `http://localhost:3000` (override with `PORT`).

Point the Swift app at:

- Simulator: `http://localhost:3000`
- Physical device: `http://<your-mac-lan-ip>:3000`

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/v4/launches/query` | Paginated, filterable launches |
| `GET` | `/v4/launches/:id` | Launch details |
| `POST` | `/v4/rockets/query` | Paginated rockets |
| `GET` | `/v4/rockets/:id` | Rocket details |

Unknown IDs return `404` with body `Not Found`. Malformed query bodies return `400`.

## Example requests

Paginated launches, newest first:

```bash
curl -s http://localhost:3000/v4/launches/query \
  -H 'Content-Type: application/json' \
  -d '{"query":{},"options":{"page":1,"limit":5,"sort":{"date_utc":"desc"}}}'
```

Filter launches by date interval (assignment requirement):

```bash
curl -s http://localhost:3000/v4/launches/query \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "date_utc": {
        "$gte": "2017-01-01T00:00:00.000Z",
        "$lte": "2020-12-31T23:59:59.000Z"
      }
    },
    "options": { "limit": 10, "populate": ["launchpad", "rocket"] }
  }'
```

Launch details (IDs stay unpopulated, matching the original GET-one contract):

```bash
curl -s http://localhost:3000/v4/launches/5eb87d42ffd86e000604b384
```

Paginated rockets and rocket details:

```bash
curl -s http://localhost:3000/v4/rockets/query \
  -H 'Content-Type: application/json' \
  -d '{"query":{},"options":{"page":1,"limit":2}}'

curl -s http://localhost:3000/v4/rockets/5e9d0d95eda69973a809d1ec
```

`options.populate` on query routes accepts `rocket` and `launchpad` so the list screen can show a launch site and the details card can show rocket name/type without extra endpoints.
