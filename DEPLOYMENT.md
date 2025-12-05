# Deployment Guide

## Important Notes

### SQLite Database in Production
⚠️ **Warning**: SQLite is configured for production, but it requires persistent storage. If deploying with Docker, make sure to mount a volume for the `storage/` directory, otherwise your database will be lost when the container restarts.

For Docker:
```bash
docker run -v /path/to/persistent/storage:/rails/storage ...
```

For production, consider using PostgreSQL or MySQL instead of SQLite.

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

**Option 1: Environment variable in docker run**
```bash
docker run -d -p 3000:3000 \
  -e SECRET_KEY_BASE=$(bin/rails secret) \
  --name my-app my-app
```

**Option 2: Use docker-compose.yml**
Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      RAILS_ENV: production
```

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

1. Go to your project → Variables
2. Add: `SECRET_KEY_BASE` = `<generated-secret>`

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

