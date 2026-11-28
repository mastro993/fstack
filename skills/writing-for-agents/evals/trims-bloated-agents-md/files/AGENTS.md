# AGENTS.md

## About this project

Tallybook is a web application for small businesses to track invoices, expenses and payments. It is built with TypeScript, React and Node.js. The frontend uses Vite and the backend uses Express with a PostgreSQL database. We care a lot about quality and we want our code to be clean and easy to read.

## Project structure

```
apps/
  web/          # React frontend
  api/          # Express backend
packages/
  ui/           # shared React components
  db/           # database schema and migrations
  utils/        # shared helpers
scripts/        # dev scripts
legacy/         # old v1 invoice exporter
```

- `apps/web/src/pages` contains the pages
- `apps/web/src/components` contains the components
- `apps/api/src/routes` contains the API routes
- `packages/db/migrations` contains the migrations

## General rules

IMPORTANT!!! You MUST ALWAYS write clean, maintainable, well-tested code and follow best practices at all times.

- Always handle errors appropriately.
- Make sure the code is readable.
- Use npm to install dependencies.
- Don't use default exports.
- Write meaningful commit messages.

## Testing

- Until the end of Q1 2025 we are migrating from Jest to Vitest. New tests should use Vitest, old Jest tests will be converted.
- Run the tests with `pnpm test`.
- The date-formatting tests fail on machines that are not in UTC, so run them with `TZ=UTC pnpm test`.
- Always write tests for your code.

## Database

- CRITICAL: `pnpm db:reset` drops every table. Only run it against the local docker database (DATABASE_URL pointing at localhost:5433), never against staging.
- Migrations live in `packages/db/migrations`. Create a new one with `pnpm --filter db migrate:new <name>`; never edit a migration that is already merged.

## Packages

- ALWAYS use pnpm. NEVER use npm or yarn.
- Don't use default exports!!!

## Legacy

- NEVER EVER touch anything in `legacy/`. It is the v1 invoice exporter that two enterprise customers still run on their own servers, and any change has to be shipped to them by hand.
