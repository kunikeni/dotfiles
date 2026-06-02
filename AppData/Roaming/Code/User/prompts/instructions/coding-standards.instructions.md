---
name: coding-standards
description: プロジェクトと言語全体に適用可能なユニバーサルコーディング標準とベストプラクティス。
---

# Coding Standards

Universal standards applied to all code across the workspace.

## Code Organization

### File Structure

```
src/
├── api/              # API layer
│   ├── routes/
│   └── middleware/
├── services/         # Business logic
├── models/           # Data models
├── utils/            # Utilities
├── hooks/            # Custom hooks (React)
├── components/       # UI components (React)
├── config/           # Configuration
└── types/            # Type definitions
```

### Module Organization

- **One concern per file** - Don't mix different responsibilities
- **Alphabetical ordering** - Easy to find files
- **Clear naming** - File names reflect content
- **Relative imports** - Prefer relative to absolute
- **Export explicitly** - Don't use default exports for utilities

## Naming Conventions

### Files

- **Components**: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- **Utilities**: `camelCase.ts` (e.g., `formatDate.ts`)
- **Tests**: `*.test.ts` or `*.spec.ts`
- **Constants**: `UPPER_SNAKE_CASE` in separate files

### Variables & Functions

```typescript
// Booleans
const isActive = true
const hasError = false
const canDelete = true

// Functions
function calculateTotal(items: Item[]): number {}
function validateEmail(email: string): boolean {}

// Constants
const MAX_RETRIES = 3
const DEFAULT_TIMEOUT = 5000
```

### Classes

```typescript
class UserService {
  private database: Database
  private logger: Logger

  async fetchUser(id: string): Promise<User> {}
}
```

## Code Quality

### Error Handling

```typescript
// Always handle errors
try {
  const result = await operation()
} catch (error) {
  if (error instanceof ValidationError) {
    // Handle validation error
  } else if (error instanceof NotFoundError) {
    // Handle not found
  } else {
    // Handle unexpected error
    logger.error('Unexpected error', { error, context })
    throw new ApplicationError('Operation failed')
  }
}
```

### Function Size

- Maximum 50 lines per function
- One level of abstraction per function
- Extract complex logic to helper functions
- Use descriptive names instead of comments

### Immutability

```typescript
// Good: Create new objects instead of mutating
const updatedUser = { ...user, name: 'John' }
const newArray = [...array, item]
const newMap = new Map(oldMap).set(key, value)

// Avoid: Mutating existing objects
user.name = 'John'
array.push(item)
map.set(key, value)
```

### Type Safety

```typescript
// Use specific types, not any
// ❌ Avoid
const process = (data: any): any => {}

// ✅ Good
const process = (data: UserData): ProcessResult => {}

// Use discriminated unions for complex types
type Result =
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error }
```

### Comments

```typescript
// ✅ Good: Explain WHY, not WHAT
// Using string concatenation instead of template literals
// for compatibility with older environments
const message = 'Hello ' + name

// ❌ Avoid: Restating the code
// Add one to count
count = count + 1
```

## Testing Standards

### Test Coverage

- Minimum 80% line coverage
- 100% coverage for critical paths
- Edge cases and error scenarios covered
- Integration tests for API endpoints

### Test Organization

```typescript
describe('calculateTotal', () => {
  describe('with valid items', () => {
    it('sums items correctly', () => {})
    it('handles decimal values', () => {})
  })

  describe('with invalid items', () => {
    it('throws error for negative values', () => {})
    it('throws error for null items', () => {})
  })

  describe('edge cases', () => {
    it('returns 0 for empty array', () => {})
  })
})
```

### Assertions

```typescript
// Use specific assertions
expect(result).toBe(expected)
expect(array).toHaveLength(3)
expect(fn).toThrow(TypeError)
expect(text).toMatch(/pattern/)

// Avoid vague assertions
expect(result).toBeTruthy()  // Too vague
expect(array).toBeDefined()  // Should check value
```

## Formatting

### Line Length

- Maximum 100 characters per line
- Break long lines logically
- Indent with 2 spaces (consistent with project)

### Whitespace

```typescript
// Good spacing for readability
const users = fetchUsers()
const active = users.filter(u => u.isActive)
const sorted = active.sort((a, b) => a.name.localeCompare(b.name))

// Return early to reduce nesting
function processUser(user: User): void {
  if (!user.isValid) return
  if (user.isDeleted) return

  // Process valid, active user
  handleUser(user)
}
```

## Documentation

### Function Documentation

```typescript
/**
 * Calculates the total price including tax.
 * @param items - Array of items with prices
 * @param taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @returns Total price including tax
 * @throws {ValidationError} If items is empty or tax rate is negative
 */
function calculateTotal(items: Item[], taxRate: number): number {
  // Implementation
}
```

### README

Every project should have:

- What the project does
- How to set up
- How to run tests
- How to deploy
- Project structure overview
- Key decisions and trade-offs

## Performance

### Common Optimizations

```typescript
// Memoize expensive computations
const memoized = useMemo(() => expensiveCalc(data), [data])

// Defer non-critical work
const [isPending, startTransition] = useTransition()

// Batch state updates
setTimeout(() => {
  setState1(a)
  setState2(b)
}, 0)
```

### Profiling

- Measure before optimizing
- Use performance tools (Lighthouse, DevTools)
- Monitor production metrics
- Track improvements over time

## Security

### Input Validation

- Validate all user input
- Use schema validation (Zod, Joi)
- Sanitize before storing
- Encode before displaying

### Secrets Management

- Never commit secrets
- Use environment variables
- Rotate credentials regularly
- Log access to sensitive data

### Dependencies

- Keep dependencies updated
- Review security advisories
- Minimize dependency count
- Use trusted sources

## Git Conventions

### Commit Messages

```
type(scope): subject

body

footer
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(auth): add two-factor authentication

Implement TOTP-based 2FA for user accounts.
Add verification endpoint and UI component.

Closes #123
```

### Branching

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code improvements


