---
name: backend-patterns
description: バックエンド設計とAPIパターン。バックエンドシステム、API、サービスを設計する際に参考にします。
---

# Backend Patterns

Architectural patterns and best practices for backend development.

## API Design

### RESTful Principles

- Use HTTP verbs correctly (GET, POST, PUT, DELETE, PATCH)
- Meaningful resource URLs (/api/users, /api/users/123)
- Consistent response format
- Proper HTTP status codes
- Versioning strategy (v1, v2)

### Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  metadata?: {
    timestamp: string
    version: string
    pagination?: {
      page: number
      total: number
      pageSize: number
    }
  }
}
```

### Error Handling

```typescript
// Consistent error responses
{
  "success": false,
  "error": "User not found",
  "metadata": {
    "code": "USER_NOT_FOUND",
    "status": 404,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Database Patterns

### Connection Management

- Use connection pooling
- Implement retry logic
- Set appropriate timeouts
- Monitor connection health
- Clean up connections on shutdown

### Query Optimization

- Index heavily-queried columns
- Use EXPLAIN ANALYZE for slow queries
- Batch operations when possible
- Avoid N+1 queries
- Cache query results appropriately

### Transaction Management

- Use transactions for related operations
- Set appropriate isolation levels
- Handle deadlocks gracefully
- Keep transactions brief
- Log transaction failures

## Service Architecture

### Separation of Concerns

- **Controllers**: HTTP handling and routing
- **Services**: Business logic
- **Repositories**: Data access
- **Middleware**: Cross-cutting concerns

### Dependency Injection

```typescript
// Service receives dependencies, doesn't create them
class UserService {
  constructor(
    private db: Database,
    private cache: CacheService,
    private logger: Logger
  ) {}
}

// Compose in main app setup
const userService = new UserService(db, cache, logger)
```

## Authentication & Authorization

### JWT Pattern

```typescript
// Generate token
const token = jwt.sign(
  { userId: user.id, role: user.role },
  SECRET,
  { expiresIn: '1h' }
)

// Verify token
const decoded = jwt.verify(token, SECRET)
```

### Permission Checks

```typescript
// Middleware for route protection
async function requireAuth(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1]
  if (!token) return res.status(401).json({ error: 'Unauthorized' })

  try {
    req.user = jwt.verify(token, SECRET)
    next()
  } catch {
    res.status(403).json({ error: 'Forbidden' })
  }
}
```

## Caching Strategy

### Cache Layers

1. **Application Cache** - In-memory (Redis)
2. **Database Cache** - Query result caching
3. **HTTP Cache** - Response caching with headers
4. **CDN Cache** - Static content delivery

### Invalidation Patterns

- **TTL-based**: Cache expires after time
- **Event-based**: Invalidate on data change
- **Manual**: Explicit cache clearing
- **Hybrid**: Combine multiple strategies

## Background Jobs

### Queue Pattern

```typescript
// Enqueue job
await jobQueue.add('send-email', {
  userId: user.id,
  subject: 'Welcome'
})

// Process job
jobQueue.process('send-email', async (job) => {
  await emailService.send(job.data)
})
```

## Logging & Monitoring

### Structured Logging

```typescript
logger.info('User login', {
  userId: user.id,
  ip: req.ip,
  timestamp: new Date().toISOString(),
  duration: endTime - startTime
})
```

### Metrics to Track

- API response times
- Error rates
- Database query performance
- Cache hit ratios
- Queue depths
- Resource utilization


