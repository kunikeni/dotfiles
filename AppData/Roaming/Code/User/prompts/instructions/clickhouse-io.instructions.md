---
name: clickhouse-io
description: OLAP分析用ClickHouseデータベースパターン。分析インフラストラクチャを設計する際に参考にします。
---

# ClickHouse Patterns

OLAP database patterns and best practices for analytics infrastructure.

## When to Use ClickHouse

- Time-series analytics
- Event stream analysis
- Large-scale aggregations
- Real-time dashboards
- Immutable audit logs
- Analytics data warehouse

## Data Modeling

### MergeTree Family

ClickHouse's primary table engine for analytics:

```sql
CREATE TABLE events (
  timestamp DateTime,
  event_id UUID,
  user_id UInt64,
  event_type String,
  properties JSON
)
ENGINE = MergeTree()
ORDER BY (timestamp, user_id)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 2 YEAR DELETE;
```

Key concepts:

- **ORDER BY**: Primary sorting key (must include)
- **PARTITION BY**: Separate files by partition
- **TTL**: Auto-delete old data

### ReplacingMergeTree for Updates

```sql
CREATE TABLE user_state (
  timestamp DateTime,
  user_id UInt64,
  status String,
  version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (user_id, timestamp)
PARTITION BY toYYYYMM(timestamp);
```

Use when data updates (keeps latest version per user).

### SummingMergeTree for Aggregates

```sql
CREATE TABLE metrics_daily (
  date Date,
  event_type String,
  count UInt64,
  duration_ms UInt64
)
ENGINE = SummingMergeTree((count, duration_ms))
ORDER BY (date, event_type)
PARTITION BY date;
```

Pre-aggregates specified columns during merge.

## Query Patterns

### Event Aggregation

```sql
-- Events per user per hour
SELECT
  user_id,
  toStartOfHour(timestamp) AS hour,
  count() AS event_count,
  uniq(event_type) AS unique_events
FROM events
WHERE timestamp >= '2024-01-01'
GROUP BY user_id, hour
ORDER BY user_id, hour;
```

### Funnel Analysis

```sql
-- Users who completed both signup and purchase
SELECT
  arrayJoin(
    arrayIntersect(
      groupArray(DISTINCT user_id) FILTER (WHERE event_type = 'signup'),
      groupArray(DISTINCT user_id) FILTER (WHERE event_type = 'purchase')
    )
  ) AS user_id
FROM events
WHERE timestamp >= '2024-01-01';
```

### Session Analytics

```sql
-- Group events into sessions (5-minute gaps)
SELECT
  user_id,
  sum(is_new_session) over (
    PARTITION BY user_id ORDER BY timestamp
  ) AS session_id,
  min(timestamp) AS session_start,
  max(timestamp) AS session_end,
  count() AS event_count
FROM (
  SELECT *,
    if(timestamp - lag(timestamp) over (
      PARTITION BY user_id ORDER BY timestamp
    ) > 300, 1, 0) AS is_new_session
  FROM events
)
GROUP BY user_id, session_id;
```

## Performance Optimization

### Compression

ClickHouse compresses data significantly:

```sql
-- Check compression ratio
SELECT
  table,
  sum(bytes) / 1024 / 1024 AS size_mb,
  sum(compressed_bytes) / 1024 / 1024 AS compressed_mb,
  (1 - compressed_bytes / bytes) * 100 AS compression_ratio
FROM system.parts
GROUP BY table;
```

### Index Strategy

```sql
-- Primary key is essential for filtering
CREATE TABLE events (
  timestamp DateTime,  -- First: TIME-based filtering
  user_id UInt64,      -- Second: COMMON filter
  event_type String,   -- Third: FREQUENT filter
  ...
)
ENGINE = MergeTree()
ORDER BY (timestamp, user_id, event_type);
```

### Partitioning

- **Partition by time**: Most common (by day/month)
- **Query filtering**: Always include partition key in WHERE
- **Data lifecycle**: Partition by time for TTL policies

## Integration Patterns

### Event Ingestion

```typescript
// Batch insert for efficiency
const events = [
  { timestamp: now, user_id: 123, event_type: 'click' },
  { timestamp: now, user_id: 124, event_type: 'view' }
]

await clickhouse.insert({
  table: 'events',
  values: events,
  format: 'JSONEachRow'
})
```

### Real-time Dashboards

```typescript
// Query for recent aggregates
const recentStats = await clickhouse.query(`
  SELECT
    event_type,
    count() as count,
    uniqExact(user_id) as unique_users
  FROM events
  WHERE timestamp > now() - INTERVAL 1 HOUR
  GROUP BY event_type
`)
```

## Data Warehousing

### Dimensional Modeling

```sql
-- Fact table: events
CREATE TABLE fact_events (
  timestamp DateTime,
  user_id UInt64,
  event_type_id UInt32,
  amount Decimal(10, 2)
)
ENGINE = MergeTree()
ORDER BY (timestamp, user_id);

-- Dimension table: users
CREATE TABLE dim_users (
  user_id UInt64,
  name String,
  country String
)
ENGINE = ReplacingMergeTree()
ORDER BY user_id;
```

## Common Pitfalls

❌ **DON'T**:

- Use without ORDER BY
- INSERT single rows (batch instead)
- Forget PARTITION BY for time data
- Use for transactional workloads
- Store frequently updating rows

✅ **DO**:

- Define PRIMARY KEY (ORDER BY)
- Batch inserts (100s or 1000s)
- Partition by time dimension
- Use for read-heavy analytics
- Archive old data with TTL


