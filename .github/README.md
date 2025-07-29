# GitHub Actions CI/CD Documentation

This directory contains GitHub Actions workflows for the Pomodoro Timer App.

## Workflows Overview

### 1. `test.yml` - Test Suite
**Triggers:** Push to main/develop, Pull requests
**Purpose:** Quick testing and validation

**Jobs:**
- **Frontend Tests**: Lint, test, and build the React frontend
- **Backend Tests**: Lint and test the Node.js backend with MongoDB
- **API Integration Tests**: Test the complete API with real database

### 2. `ci-cd.yml` - Full CI/CD Pipeline
**Triggers:** Push to main/develop, Pull requests, Manual dispatch
**Purpose:** Complete pipeline with deployment

**Jobs:**
- All test jobs from `test.yml`
- Docker build and test
- Security scanning
- Staging deployment (on main branch)
- Production deployment (manual only)

### 3. `deploy.yml` - Deployment Workflow
**Triggers:** Manual dispatch only
**Purpose:** Deploy to different platforms

**Supported Platforms:**
- Heroku
- Vercel
- Netlify
- Docker

### 4. `security.yml` - Security Scanning
**Triggers:** Push, Pull requests, Weekly schedule
**Purpose:** Security vulnerability scanning

**Jobs:**
- Dependency vulnerability scan (npm audit)
- CodeQL analysis
- Trivy vulnerability scanner
- Docker image security scan
- Secret scanning (TruffleHog)

## Setup Instructions

### 1. Enable GitHub Actions
1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Click "Enable Actions" if not already enabled

### 2. Configure Repository Secrets
Go to **Settings > Secrets and variables > Actions** and add these secrets:

#### For Heroku Deployment:
```
HEROKU_API_KEY=your_heroku_api_key
HEROKU_APP_NAME=your_heroku_app_name
```

#### For Vercel Deployment:
```
VERCEL_TOKEN=your_vercel_token
VERCEL_ORG_ID=your_vercel_org_id
VERCEL_PROJECT_ID=your_vercel_project_id
```

#### For Netlify Deployment:
```
NETLIFY_AUTH_TOKEN=your_netlify_auth_token
NETLIFY_SITE_ID=your_netlify_site_id
```

#### For Docker Deployment:
```
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
```

#### For Database (if using external MongoDB):
```
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

### 3. Add Test Scripts to package.json

#### Frontend (`client/package.json`):
```json
{
  "scripts": {
    "test": "vitest",
    "lint": "eslint . --ext js,jsx,ts,tsx",
    "build": "vite build"
  }
}
```

#### Backend (`server/package.json`):
```json
{
  "scripts": {
    "test": "jest",
    "lint": "eslint .",
    "start": "node server.js"
  }
}
```

### 4. Create Test Files

#### Frontend Tests (`client/src/__tests__/`):
```javascript
// Example test file
import { render, screen } from '@testing-library/react'
import App from '../App'

test('renders timer', () => {
  render(<App />)
  expect(screen.getByText(/timer/i)).toBeInTheDocument()
})
```

#### Backend Tests (`server/__tests__/`):
```javascript
// Example test file
const request = require('supertest')
const app = require('../server')

describe('Health endpoint', () => {
  test('GET /health returns 200', async () => {
    const response = await request(app).get('/health')
    expect(response.status).toBe(200)
  })
})
```

## Usage

### Running Tests
Tests run automatically on:
- Every push to `main` or `develop` branches
- Every pull request to `main` branch

### Manual Deployment
1. Go to **Actions** tab
2. Select **Deploy** workflow
3. Click **Run workflow**
4. Choose environment and platform
5. Click **Run workflow**

### Viewing Results
- **Actions tab**: View workflow runs and logs
- **Security tab**: View security scan results
- **Pull requests**: See test results in PR checks

## Troubleshooting

### Common Issues

#### 1. Tests Failing
- Check that all dependencies are installed
- Ensure test scripts are properly configured
- Verify environment variables are set

#### 2. Deployment Failing
- Verify secrets are correctly configured
- Check platform-specific requirements
- Review deployment logs for errors

#### 3. Security Scans Failing
- Update dependencies with known vulnerabilities
- Review and fix security issues in code
- Check for exposed secrets

### Getting Help
- Check workflow logs in the Actions tab
- Review GitHub Actions documentation
- Check platform-specific deployment guides

## Best Practices

1. **Always test before deploying**
2. **Keep dependencies updated**
3. **Review security scan results**
4. **Use staging environment first**
5. **Monitor deployment logs**
6. **Set up notifications for failures**

## Customization

You can customize these workflows by:
- Modifying trigger conditions
- Adding new test jobs
- Changing deployment platforms
- Adjusting security scan settings
- Adding custom notifications 