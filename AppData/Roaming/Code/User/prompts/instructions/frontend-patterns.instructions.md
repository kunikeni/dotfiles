---
name: frontend-patterns
description: ReactとNext.jsのコンポーネントパターン、状態管理、パフォーマンス最適化、ベストプラクティス。
---

# Frontend Patterns

React and Next.js architectural patterns, component design, and performance best practices.

## Component Architecture

### Composition Over Inheritance

Compose smaller components into larger ones:

```typescript
// ✅ Good: Composition
function UserCard({ user, onDelete }: Props) {
  return (
    <Card>
      <CardHeader>
        <UserAvatar user={user} />
        <UserName user={user} />
      </CardHeader>
      <CardBody>
        <UserBio user={user} />
      </CardBody>
      <CardFooter>
        <DeleteButton onClick={onDelete} />
      </CardFooter>
    </Card>
  )
}

// ❌ Avoid: Deep inheritance hierarchies
class BaseUserComponent extends React.Component {}
class UserCard extends BaseUserComponent {}
```

### Compound Components

Components that work together as a system:

```typescript
// Define compound component API
<Dialog>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Header>Title</Dialog.Header>
    <Dialog.Body>Content</Dialog.Body>
    <Dialog.Footer>
      <Dialog.Close>Cancel</Dialog.Close>
      <Dialog.Action>Confirm</Dialog.Action>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog>

// Implementation
const DialogContext = createContext()

export function Dialog({ children }: Props) {
  const [open, setOpen] = useState(false)
  return (
    <DialogContext.Provider value={{ open, setOpen }}>
      {children}
    </DialogContext.Provider>
  )
}

Dialog.Trigger = function Trigger({ children }: Props) {
  const { setOpen } = useContext(DialogContext)
  return (
    <button onClick={() => setOpen(true)}>
      {children}
    </button>
  )
}

// ... other subcomponents
```

### Render Props Pattern

Flexible component reuse:

```typescript
interface RenderPropsProps {
  children?: (state: State) => React.ReactNode
  render?: (state: State) => React.ReactNode
}

function DataFetcher({ url, render, children }: RenderPropsProps) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data)
        setLoading(false)
      })
  }, [url])

  const renderFn = render || children
  return renderFn({ data, loading })
}

// Usage
<DataFetcher url="/api/users">
  {({ data, loading }) => (
    loading ? <Spinner /> : <UserList users={data} />
  )}
</DataFetcher>
```

## State Management

### useState for Simple State

```typescript
// Single value
const [count, setCount] = useState(0)

// Multiple related values - group together
const [form, setForm] = useState({
  name: '',
  email: '',
  password: ''
})

const handleChange = (field: string, value: string) => {
  setForm(prev => ({ ...prev, [field]: value }))
}
```

### useReducer for Complex State

```typescript
type Action =
  | { type: 'SET_LOADING' }
  | { type: 'SET_DATA'; payload: Data }
  | { type: 'SET_ERROR'; payload: Error }
  | { type: 'RESET' }

const initialState: State = {
  loading: false,
  data: null,
  error: null
}

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: true }
    case 'SET_DATA':
      return { loading: false, data: action.payload, error: null }
    case 'SET_ERROR':
      return { loading: false, data: null, error: action.payload }
    case 'RESET':
      return initialState
  }
}

// Usage
const [state, dispatch] = useReducer(reducer, initialState)

const fetchData = async () => {
  dispatch({ type: 'SET_LOADING' })
  try {
    const data = await api.fetch()
    dispatch({ type: 'SET_DATA', payload: data })
  } catch (error) {
    dispatch({ type: 'SET_ERROR', payload: error })
  }
}
```

### Context for Global State

```typescript
// Create context
interface ThemeContextType {
  theme: 'light' | 'dark'
  toggleTheme: () => void
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

// Provider
function ThemeProvider({ children }: Props) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light')
  }

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

// Hook
function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme must be used inside ThemeProvider')
  }
  return context
}

// Usage
function MyComponent() {
  const { theme, toggleTheme } = useTheme()
  return (
    <div className={`theme-${theme}`}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </div>
  )
}
```

## Performance Optimization

### Memoization

```typescript
// Memoize expensive computations
function UserList({ users }: Props) {
  const sortedUsers = useMemo(() => {
    return users.sort((a, b) => a.name.localeCompare(b.name))
  }, [users])

  return (
    <div>
      {sortedUsers.map(user => (
        <UserItem key={user.id} user={user} />
      ))}
    </div>
  )
}

// Memoize callbacks
const handleDelete = useCallback((id: string) => {
  setUsers(prev => prev.filter(u => u.id !== id))
}, [])

// Memoize components
const UserItem = memo(function UserItem({ user }: Props) {
  return <div>{user.name}</div>
})
```

### Code Splitting

```typescript
// Dynamic imports for large components
const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyComponent />
    </Suspense>
  )
}

// Route-based code splitting
const Home = lazy(() => import('./pages/Home'))
const About = lazy(() => import('./pages/About'))

function Router() {
  return (
    <Suspense fallback={<PageSpinner />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
      </Routes>
    </Suspense>
  )
}
```

### Image Optimization

```typescript
// Use Next.js Image component
import Image from 'next/image'

function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority  // Load eagerly
      sizes="(max-width: 768px) 100vw, 1200px"  // Responsive
    />
  )
}
```

## Best Practices Checklist

### Component Design

- [ ] Single responsibility principle
- [ ] Props are clearly documented (JSDoc)
- [ ] Prop validation with TypeScript
- [ ] Default props provided when appropriate
- [ ] Children prop used correctly
- [ ] Key prop provided in lists

### State Management

- [ ] State is collocated as close to use as possible
- [ ] No derived state (calculated from props)
- [ ] State updates are batched
- [ ] Unnecessary re-renders are prevented
- [ ] State shape is normalized
- [ ] Async operations are handled

### Performance

- [ ] Images are optimized and responsive
- [ ] Bundles are code-split appropriately
- [ ] Expensive computations are memoized
- [ ] Event handlers are memoized when passed to child components
- [ ] Components re-render only when necessary
- [ ] No layout thrashing

### Accessibility

- [ ] Semantic HTML is used (button, nav, header)
- [ ] ARIA labels provided where needed
- [ ] Keyboard navigation works
- [ ] Color contrast meets WCAG standards
- [ ] Form labels are associated with inputs
- [ ] Alt text provided for images

### Security

- [ ] User input is sanitized
- [ ] XSS protection in place
- [ ] CSP headers configured
- [ ] No sensitive data in localStorage
- [ ] API calls use HTTPS
- [ ] CSRF tokens used for state-changing operations

### Testing

- [ ] Unit tests for component logic
- [ ] Integration tests for user interactions
- [ ] E2E tests for critical flows
- [ ] Accessibility tests
- [ ] Visual regression tests
- [ ] Coverage ≥ 80%

### Maintainability

- [ ] Code is well-organized
- [ ] Naming is clear and consistent
- [ ] Complex logic is extracted to hooks
- [ ] No deeply nested components
- [ ] Comments explain "why", not "what"
- [ ] Dependencies are updated regularly

## Common Patterns

### Data Fetching

```typescript
function useData<T>(url: string) {
  const [state, dispatch] = useReducer(reducer, initialState)

  useEffect(() => {
    let mounted = true

    const fetchData = async () => {
      dispatch({ type: 'SET_LOADING' })
      try {
        const response = await fetch(url)
        if (!response.ok) throw new Error('Failed to fetch')
        const data = await response.json()

        if (mounted) {
          dispatch({ type: 'SET_DATA', payload: data })
        }
      } catch (error) {
        if (mounted) {
          dispatch({ type: 'SET_ERROR', payload: error })
        }
      }
    }

    fetchData()

    return () => {
      mounted = false  // Cleanup
    }
  }, [url])

  return state
}
```

### Form Handling

```typescript
function useForm<T>(initialValues: T) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState<Record<string, string>>({})

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setValues(prev => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (onSubmit: (values: T) => Promise<void>) => {
    return (e: React.FormEvent) => {
      e.preventDefault()
      onSubmit(values).catch(error => {
        setErrors({ form: error.message })
      })
    }
  }

  return { values, errors, handleChange, handleSubmit }
}
```

## Next.js Specific Patterns

### Server Components

```typescript
// app/page.tsx - Server component by default
export default async function Home() {
  const data = await fetchData()  // OK: async is fine
  return <div>{data}</div>
}
```

### Client Components

```typescript
'use client'

import { useState } from 'react'

// app/components/Counter.tsx - Must be client component for interactivity
export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Data Patterns

```typescript
// API Route
// app/api/users/route.ts
export async function GET(request: Request) {
  const users = await db.users.findMany()
  return Response.json(users)
}

// Server Action
// app/actions.ts
'use server'

export async function updateUser(id: string, data: unknown) {
  const validated = validateUserInput(data)
  return await db.users.update({ where: { id }, data: validated })
}
```

## Related Skills

- See `coding-standards` for general naming and organization
- See `tdd-workflow` for testing patterns
- See `verification-loop` for performance verification


