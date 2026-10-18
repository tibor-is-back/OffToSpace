import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import cors from 'cors';
import express from 'express';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataDir = join(__dirname, 'data');

const launches = JSON.parse(readFileSync(join(dataDir, 'launches.json'), 'utf8'));
const rockets = JSON.parse(readFileSync(join(dataDir, 'rockets.json'), 'utf8'));
const launchpads = JSON.parse(readFileSync(join(dataDir, 'launchpads.json'), 'utf8'));

const DEFAULT_LIMIT = 10;
const DEFAULT_PAGE = 1;
const SORTABLE_FIELDS = new Set(['date_utc', 'flight_number', 'name', 'first_flight']);
const POPULATE_PATHS = new Set(['rocket', 'launchpad']);
const COMPARISON_OPS = new Set(['$gte', '$lte', '$gt', '$lt']);

const lookups = {
  rocket: new Map(rockets.map((rocket) => [rocket.id, rocket])),
  launchpad: new Map(launchpads.map((pad) => [pad.id, pad])),
};

const app = express();
app.use(cors());
app.use(express.json({ strict: false }));

app.post('/v4/launches/query', (req, res) => {
  handleQuery(req, res, launches, { defaultSort: { date_utc: 'desc' } });
});

app.get('/v4/launches/:id', (req, res) => {
  const launch = launches.find((item) => item.id === req.params.id);
  if (!launch) {
    return res.status(404).type('text/plain').send('Not Found');
  }
  res.json(structuredClone(launch));
});

app.post('/v4/rockets/query', (req, res) => {
  handleQuery(req, res, rockets, { defaultSort: { first_flight: 'asc' } });
});

app.get('/v4/rockets/:id', (req, res) => {
  const rocket = rockets.find((item) => item.id === req.params.id);
  if (!rocket) {
    return res.status(404).type('text/plain').send('Not Found');
  }
  res.json(structuredClone(rocket));
});

app.use((error, _req, res, _next) => {
  if (error instanceof SyntaxError && 'body' in error) {
    return res.status(400).json({ error: 'Invalid JSON body' });
  }
  res.status(400).json({ error: error.message || 'Bad Request' });
});

function handleQuery(req, res, collection, { defaultSort }) {
  try {
    const { query, options } = parseQueryBody(req.body);
    const filtered = collection.filter((doc) => matchesQuery(doc, query));
    const sorted = sortDocs(filtered, options.sort || defaultSort);
    const page = paginate(sorted, options);
    page.docs = page.docs.map((doc) => applyPopulate(doc, options.populate));
    res.json(page);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

function parseQueryBody(body) {
  if (body == null) {
    return { query: {}, options: {} };
  }
  if (typeof body !== 'object' || Array.isArray(body)) {
    throw new Error('Request body must be a JSON object');
  }

  const query = body.query ?? {};
  const options = body.options ?? {};

  if (typeof query !== 'object' || Array.isArray(query)) {
    throw new Error('query must be an object');
  }
  if (typeof options !== 'object' || Array.isArray(options)) {
    throw new Error('options must be an object');
  }

  return { query, options };
}

function matchesQuery(doc, query) {
  return Object.entries(query).every(([field, condition]) =>
    fieldMatches(doc, field, condition),
  );
}

function fieldMatches(doc, field, condition) {
  const value = field === '_id' ? doc.id : doc[field];

  if (isPlainObject(condition)) {
    return Object.entries(condition).every(([operator, expected]) => {
      if (!COMPARISON_OPS.has(operator)) {
        throw new Error(`Unsupported operator ${operator}`);
      }
      if (value == null || expected == null) {
        return false;
      }
      if (operator === '$gte') return value >= expected;
      if (operator === '$lte') return value <= expected;
      if (operator === '$gt') return value > expected;
      return value < expected;
    });
  }

  return value === condition;
}

function sortDocs(docs, sort) {
  const { field, direction } = parseSort(sort);
  if (!field) {
    return [...docs];
  }

  return [...docs].sort((left, right) => {
    const a = left[field];
    const b = right[field];
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    if (a < b) return -1 * direction;
    if (a > b) return 1 * direction;
    return 0;
  });
}

function parseSort(sort) {
  if (!sort) {
    return { field: null, direction: 1 };
  }

  if (typeof sort === 'string') {
    const descending = sort.startsWith('-');
    const field = descending ? sort.slice(1) : sort;
    assertSortable(field);
    return { field, direction: descending ? -1 : 1 };
  }

  if (isPlainObject(sort)) {
    const [field, rawDirection] = Object.entries(sort)[0] ?? [];
    if (!field) {
      return { field: null, direction: 1 };
    }
    assertSortable(field);
    const descending = rawDirection === 'desc' || rawDirection === -1 || rawDirection === '-1';
    return { field, direction: descending ? -1 : 1 };
  }

  throw new Error('sort must be a string or object');
}

function assertSortable(field) {
  if (!SORTABLE_FIELDS.has(field)) {
    throw new Error(`Unsupported sort field ${field}`);
  }
}

function paginate(docs, options) {
  const limit = normalizePositiveInt(options.limit, DEFAULT_LIMIT);
  const page = normalizePositiveInt(options.page, DEFAULT_PAGE);
  const totalDocs = docs.length;
  const totalPages = Math.max(1, Math.ceil(totalDocs / limit) || 1);
  const offset = (page - 1) * limit;
  const hasPrevPage = page > 1;
  const hasNextPage = page < totalPages && offset < totalDocs;

  return {
    docs: docs.slice(offset, offset + limit).map((doc) => structuredClone(doc)),
    totalDocs,
    offset,
    limit,
    totalPages,
    page,
    pagingCounter: totalDocs === 0 ? 0 : offset + 1,
    hasPrevPage,
    hasNextPage,
    prevPage: hasPrevPage ? page - 1 : null,
    nextPage: hasNextPage ? page + 1 : null,
  };
}

function normalizePositiveInt(value, fallback) {
  if (value == null || value === '') {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1) {
    throw new Error('page and limit must be positive integers');
  }
  return parsed;
}

function applyPopulate(doc, populate) {
  const paths = parsePopulate(populate);
  for (const path of paths) {
    if (!POPULATE_PATHS.has(path)) {
      throw new Error(`Unsupported populate path ${path}`);
    }
    if (typeof doc[path] !== 'string') {
      continue;
    }
    const related = lookups[path].get(doc[path]);
    if (related) {
      doc[path] = structuredClone(related);
    }
  }
  return doc;
}

function parsePopulate(populate) {
  if (populate == null || populate === '') {
    return [];
  }

  const items = Array.isArray(populate) ? populate : [populate];
  return items.map((item) => {
    if (typeof item === 'string') {
      return item;
    }
    if (isPlainObject(item) && typeof item.path === 'string') {
      return item.path;
    }
    throw new Error('populate items must be a path string or { path }');
  });
}

function isPlainObject(value) {
  return value != null && typeof value === 'object' && !Array.isArray(value);
}

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => {
  console.log(`SpaceX mock API listening on http://localhost:${port}`);
});
