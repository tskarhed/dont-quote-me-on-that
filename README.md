# Don't Quote Me On That

A quotes management application built with SvelteKit and Supabase. This app allows allowlisted users to view and add quotes, with admin users having full access to manage quotes and the allowlist.

## Features

- **User Authentication**: Sign up and log in with email/password via Supabase Auth
- **Allowlist System**: Only allowlisted users can view and add quotes
- **Admin Role**: Admins have full access to manage quotes and the allowlist
- **Quote Management**: Add quotes with text and author information
- **Pagination**: Efficiently load quotes with pagination support
- **PWA Support**: Progressive Web App capabilities for offline access
- **Row Level Security**: Database-level security policies for data protection

## Tech Stack

- **Frontend**: SvelteKit 5, TypeScript
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Styling**: CSS
- **Build Tool**: Vite

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v18 or higher)
- [npm](https://www.npmjs.com/) or [pnpm](https://pnpm.io/)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (for local development)

### Installing Supabase CLI

```sh
# macOS
brew install supabase/tap/supabase

# Windows (using Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Linux
npm install -g supabase
```

Verify the installation:

```sh
supabase --version
```

## Getting Started

### 1. Clone and Install Dependencies

```sh
# Clone the repository (if not already done)
git clone <repository-url>
cd dont-quote-me-on-that

# Install dependencies
npm install
```

### 2. Set Up Supabase Locally

Start the local Supabase instance:

```sh
# Start Supabase locally (this will start Docker containers)
supabase start
```

This command will:
- Start PostgreSQL database on port `54322`
- Start Supabase API on port `54321`
- Start Supabase Studio on port `54323`
- Start Inbucket (email testing) on port `54324`

After starting, you'll see output with connection details. Save these values for the next step.

### 3. Configure Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<your-anon-key>
```

You can find these values in the output from `supabase start`, or by running:

```sh
supabase status
```

The `anon key` is the `anon` key from the API keys section.

### 4. Run Database Migrations

The database schema is already defined in `supabase/migrations/0001_init.sql`. When you start Supabase, migrations run automatically. To manually apply migrations:

```sh
supabase db reset
```

This will:
- Apply all migrations
- Run seed data from `supabase/seed.sql`

### 5. Seed the Database (Optional)

The seed file (`supabase/seed.sql`) includes test data:
- **Admin user**: `admin@example.com` / `password123`
- **Allowlisted user**: `user@example.com` / `password123`
- **Non-allowlisted user**: `outsider@example.com` / `password123`
- Sample quotes (including XSS test cases)

To reset and seed the database:

```sh
supabase db reset
```

### 6. Start the Development Server

```sh
npm run dev

# Or open the app automatically in your browser
npm run dev -- --open
```

The app will be available at `http://localhost:5173` (or the port shown in the terminal).

## Development Workflow

### Working with Supabase Locally

#### Viewing the Database

Access Supabase Studio (the local admin interface):

```sh
# Open Studio in your browser
supabase studio
```

Or visit `http://127.0.0.1:54323` directly.

#### Managing Migrations

Create a new migration:

```sh
supabase migration new <migration_name>
```

Apply migrations:

```sh
supabase db reset  # Resets and applies all migrations
# or
supabase migration up  # Applies pending migrations
```

#### Viewing Logs

```sh
# View all logs
supabase logs

# View specific service logs
supabase logs db
supabase logs api
```

#### Stopping Supabase

```sh
supabase stop
```

#### Resetting the Database

To completely reset your local database (useful when testing migrations):

```sh
supabase db reset
```

### Testing Email Functionality

When running Supabase locally, emails are not actually sent. Instead, they're captured by Inbucket. View test emails at:

```
http://127.0.0.1:54324
```

### Database Schema

The application uses the following main tables:

- **`profiles`**: User profiles with role information (admin/user)
- **`allowlist`**: Email addresses allowed to access quotes
- **`quotes`**: The quotes themselves with text, author, and metadata

All tables have Row Level Security (RLS) policies enabled for secure access control.

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run check` - Run Svelte type checking
- `npm run check:watch` - Run type checking in watch mode
- `npm run format` - Format code with Prettier
- `npm run lint` - Lint code with ESLint and Prettier

## Project Structure

```
dont-quote-me-on-that/
├── src/
│   ├── lib/
│   │   ├── components/      # Svelte components (Quote, etc.)
│   │   ├── stores.ts         # Svelte stores (user state)
│   │   ├── supabaseClient.ts # Supabase client configuration
│   │   └── types.ts          # TypeScript type definitions
│   └── routes/               # SvelteKit routes
│       ├── +page.svelte      # Main quotes page
│       ├── +layout.svelte    # Root layout
│       ├── login/            # Login page
│       ├── signup/           # Signup page
│       └── admin/            # Admin panel
├── supabase/
│   ├── config.toml          # Supabase local configuration
│   ├── migrations/          # Database migrations
│   └── seed.sql             # Seed data
├── static/                  # Static assets
└── package.json
```

## Troubleshooting

### Supabase won't start

- Ensure Docker is running (Supabase CLI uses Docker)
- Check if ports 54321-54324 are available
- Try `supabase stop` then `supabase start` again

### Environment variables not working

- Ensure `.env` file is in the root directory
- Restart the development server after changing `.env`
- Verify the values match those from `supabase status`

### Database connection errors

- Verify Supabase is running: `supabase status`
- Check that migrations have been applied: `supabase db reset`
- Ensure environment variables are correct

### Can't log in with test users

- Ensure seed data has been loaded: `supabase db reset`
- Check Inbucket for confirmation emails if email confirmation is enabled
- Verify the user exists in Supabase Studio

## Building for Production

```sh
npm run build
```

The production build will be in the `.svelte-kit` directory. To preview:

```sh
npm run preview
```

> **Note**: For production deployment, you'll need to configure environment variables with your production Supabase project URL and keys.

## Additional Resources

- [SvelteKit Documentation](https://kit.svelte.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli/introduction)
- [Local Development Guide](https://supabase.com/docs/guides/cli/local-development)
