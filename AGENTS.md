# Project Rules and Conventions

## UI/UX Standards
- Use **Glassmorphism** for all cards and panels (`background: rgba(var(--bg-rgb), 0.7); backdrop-filter: blur(10px);`).
- Prefer **Lucide** icons for visual indicators.
- Use **Inter** as the primary font.
- Ensure all interactive elements have hover effects and transition animations.
- Dark mode is the default and should be maintained throughout.

## Frontend Development
- Use `fetch` with centralized error handling (Toast notifications).
- Maintain an SPA architecture using the `switchView` pattern.
- Avoid global variables unless necessary; use `window.appState` or similar for shared data.
- Format currencies using `Intl.NumberFormat`.

## Backend Development
- All API responses should follow the `{"data": ..., "message": ...}` structure.
- Use **parameterized SQL queries** to prevent injections.
- Log errors details to the console/logging system, but return user-friendly messages.
- Ensure database connections are always closed (use `try...finally`).

## Database
- All custom procurement tables should reside in the `EnterpriseAdmin_AMC.Procurement` schema.
- Native Saint tables (dbo schema) should be treated as read-only where possible, except via official transaction paths.
