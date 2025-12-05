# Deployment Guide

## Database Configuration

This application uses:
- **SQLite** for development and test environments
- **PostgreSQL** for production

### PostgreSQL Configuration

Set these environment variables for production:

```bash
DATABASE_HOST=localhost          # or your PostgreSQL host
DATABASE_PORT=5432              # PostgreSQL port
DATABASE_NAME=aiaicodereview_production
DATABASE_USER=postgres          # your PostgreSQL username
DATABASE_PASSWORD=your_password # your PostgreSQL password
```

Or use `DATABASE_URL` format:
```bash
DATABASE_URL=postgresql://user:password@host:5432/database_name
```

---

## Setting SECRET_KEY_BASE

### Quick Fix

Generate a secret key:
```bash
bin/rails secret
```

Then set it as an environment variable in your deployment platform.

## Platform-Specific Instructions

### Docker / Docker Compose

**Option 1: Environment variable in docker run (with external PostgreSQL)**
```bash
docker run -d -p 3000:3000 \
  -e SECRET_KEY_BASE=$(bin/rails secret) \
  -e DATABASE_HOST=your-postgres-host \
  -e DATABASE_NAME=aiaicodereview_production \
  -e DATABASE_USER=postgres \
  -e DATABASE_PASSWORD=your-password \
  --name my-app my-app
```

**Option 2: Use docker-compose.yml (includes PostgreSQL service)**
Copy `docker-compose.yml.example` to `docker-compose.yml`:
```bash
cp docker-compose.yml.example docker-compose.yml
```

Then set your secrets:
```bash
export SECRET_KEY_BASE=$(bin/rails secret)
export POSTGRES_PASSWORD=your-secure-password
docker-compose up -d
```

The docker-compose.yml includes a PostgreSQL service that will be automatically set up.

Then run:
```bash
export SECRET_KEY_BASE=$(bin/rails secret)
docker-compose up -d
```

### Heroku

```bash
heroku config:set SECRET_KEY_BASE=$(bin/rails secret) -a your-app-name
```

Or in Heroku Dashboard:
1. Go to Settings → Config Vars
2. Add: `SECRET_KEY_BASE` = `<generated-secret>`

### Railway

Railway automatically provides `DATABASE_URL` when you add a PostgreSQL service. You need to:

1. **Add PostgreSQL service** in Railway (if not already added)
   - Go to your project → New → Database → Add PostgreSQL
   - Railway will automatically set `DATABASE_URL` environment variable

2. **Set SECRET_KEY_BASE**:
   - Go to your project → Variables (or your Rails service → Variables)
   - Add: `SECRET_KEY_BASE` = `<generated-secret>`
   - Generate secret: `bin/rails secret`

3. **Set Deploy Command** (to create database and run migrations):
   - Go to your Rails service → Settings → Deploy
   - Set Deploy Command: `bin/rails db:prepare`
   - Or leave blank to use the default (docker-entrypoint handles it)

4. **If database doesn't exist**, run migrations manually:
   - Go to your Rails service → Deployments → Click on a deployment → View Logs
   - Or use Railway CLI: `railway run bin/rails db:create db:migrate`

**Note**: Railway automatically sets `DATABASE_URL`, so you don't need to configure individual database variables (DATABASE_HOST, DATABASE_USER, etc.). The app will use `DATABASE_URL` automatically.

### Render

1. Go to your service → Environment
2. Add: `SECRET_KEY_BASE` = `<generated-secret>`

### DigitalOcean App Platform

1. Go to App Settings → App-Level Environment Variables
2. Add: `SECRET_KEY_BASE` = `<generated-secret>`

### AWS / ECS / EC2

**ECS Task Definition:**
```json
{
  "environment": [
    {
      "name": "SECRET_KEY_BASE",
      "value": "<your-secret-key>"
    }
  ]
}
```

**EC2 / EC2 with Docker:**
```bash
export SECRET_KEY_BASE=$(bin/rails secret)
# Or add to /etc/environment or ~/.bashrc
```

### GitHub Actions / CI/CD

In your workflow file:
```yaml
env:
  SECRET_KEY_BASE: ${{ secrets.SECRET_KEY_BASE }}
```

Then add `SECRET_KEY_BASE` to your repository secrets.

### Using RAILS_MASTER_KEY Instead

If you prefer to use Rails credentials:

1. Get your master key from `config/master.key` (if you have it)
2. Set environment variable: `RAILS_MASTER_KEY=<value-from-master.key>`

## Generate Secret Key

Run this command to generate a new secret:
```bash
bin/rails secret
```

**Important:** 
- Keep your secret key secure
- Never commit it to git
- Use different secrets for different environments
- Store it in your platform's secrets/environment variables system

