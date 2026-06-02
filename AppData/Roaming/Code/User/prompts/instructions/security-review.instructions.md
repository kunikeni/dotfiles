---
name: security-review
description: 認証、入力検証、シークレット管理、機密機能のための包括的なセキュリティチェックリストとパターン。
---

# Security Review Skill

This skill ensures all code follows security best practices and identifies potential vulnerabilities.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Security Checklist

### 1. Secrets Management

#### ❌ NEVER Do This

```typescript
const apiKey = "sk-proj-xxxxx"  // Hardcoded secret
const dbPassword = "password123" // In source code
```

#### ✅ ALWAYS Do This

```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL

// Verify secrets exist
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

#### Verification Steps

- [ ] No hardcoded API keys, tokens, or passwords
- [ ] All secrets in environment variables
- [ ] `.env.local` in .gitignore
- [ ] No secrets in git history
- [ ] Production secrets in hosting platform (Vercel, Railway)

### 2. Input Validation

#### Always Validate User Input

```typescript
import { z } from 'zod'

// Define validation schema
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

// Validate before processing
export async function createUser(input: unknown) {
  try {
    const validated = CreateUserSchema.parse(input)
    return await db.users.create(validated)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors }
    }
    throw error
  }
}
```

#### File Upload Validation

```typescript
function validateFileUpload(file: File) {
  // Size check (5MB max)
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    throw new Error('File too large (max 5MB)')
  }

  // Type check
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type')
  }

  // Extension check
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif']
  const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0]
  if (!extension || !allowedExtensions.includes(extension)) {
    throw new Error('Invalid file extension')
  }

  return true
}
```

### 3. Authentication & Authorization

#### Session Management

```typescript
// Use secure cookies (HTTP-only, Secure flag)
res.setHeader('Set-Cookie', [
  `session=${token}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=3600`
])

// Verify session on protected routes
export async function verifySession(req: Request) {
  const session = req.cookies.get('session')
  if (!session?.value) return null

  const user = await db.sessions.findUnique({
    where: { token: session.value }
  })

  return user
}
```

#### CSRF Protection

```typescript
// Generate CSRF token
const csrfToken = crypto.randomUUID()

// Include in forms
<form method="POST">
  <input type="hidden" name="csrf" value={csrfToken} />
</form>

// Verify on submission
if (req.body.csrf !== req.session.csrfToken) {
  throw new Error('CSRF token invalid')
}
```

### 4. Data Protection

#### Encrypt Sensitive Fields

```typescript
import crypto from 'crypto'

function encryptData(data: string): string {
  const iv = crypto.randomBytes(16)
  const cipher = crypto.createCipheriv('aes-256-gcm', Buffer.from(ENCRYPTION_KEY), iv)

  let encrypted = cipher.update(data, 'utf8', 'hex')
  encrypted += cipher.final('hex')

  const authTag = cipher.getAuthTag()
  return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`
}

function decryptData(encrypted: string): string {
  const [iv, authTag, data] = encrypted.split(':')
  const decipher = crypto.createDecipheriv(
    'aes-256-gcm',
    Buffer.from(ENCRYPTION_KEY),
    Buffer.from(iv, 'hex')
  )

  decipher.setAuthTag(Buffer.from(authTag, 'hex'))
  let decrypted = decipher.update(data, 'hex', 'utf8')
  decrypted += decipher.final('utf8')

  return decrypted
}
```

#### Password Hashing

```typescript
import bcrypt from 'bcrypt'

// Hash password on registration
const hashedPassword = await bcrypt.hash(plainPassword, 10)

// Verify password on login
const isValid = await bcrypt.compare(plainPassword, hashedPassword)
```

### 5. API Security

#### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests'
})

app.post('/api/login', limiter, handleLogin)
```

#### SQL Injection Prevention

```typescript
// ✅ GOOD: Parameterized queries
const user = await db.users.findFirst({
  where: { email: userInput }
})

// ❌ BAD: String concatenation
const query = `SELECT * FROM users WHERE email = '${userInput}'`
```

### 6. Audit Logging

```typescript
interface AuditLog {
  action: string
  userId: string
  resource: string
  timestamp: Date
  ip: string
  success: boolean
}

async function logAction(log: AuditLog) {
  await db.auditLogs.create({
    data: log
  })
}

// Usage
await logAction({
  action: 'user_login',
  userId: user.id,
  resource: 'auth',
  timestamp: new Date(),
  ip: req.ip,
  success: true
})
```

## Best Practices

- Principle of least privilege - give users/services minimum permissions needed
- Defense in depth - multiple layers of security
- Fail securely - don't expose sensitive info in errors
- Keep dependencies updated - regular security patches
- Security audits - regular code review for vulnerabilities
- Incident response plan - know how to respond to breaches


