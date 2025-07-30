# Pomodoro Timer App
![CI-CD](https://github.com/westondcrewe/pomodoro-timer-app/actions/workflows/ci-cd.yml/badge.svg)
![Deploy](https://github.com/westondcrewe/pomodoro-timer-app/actions/workflows/deploy.yml/badge.svg)
![Security](https://github.com/westondcrewe/pomodoro-timer-app/actions/workflows/security.yml/badge.svg)
![Test 1](https://github.com/westondcrewe/pomodoro-timer-app/actions/workflows/test.yml/badge.svg)

## Overview
The Pomodoro Timer App is a full-stack productivity tool designed to help users manage their work and break intervals using the Pomodoro Technique. The application enables users to track their worktime management habits, visualize session statistics, and build better focus routines.

## Tech Stack
- **Frontend:** React, Vite for build, TailwindCSS for UI
- **Backend:** Node.js with Express.js
- **Database:** MongoDB for storage of user work session statistics
- **Other:** TypeScript, custom React hooks, modular component architecture

## Features
- Interactive Pomodoro timer with work/break cycles
- Session statistic tracking for start time and Pomodoro round count (worktime management habits) stored in MongoDB
- System notifications and optional sound alerts for background operation

## How It Works
- The frontend provides a single-page application for timer control, session display, and statistics.
- The backend exposes RESTful APIs for user data and session tracking, connecting to a MongoDB database.
- Users can run the timer in the background and receive notifications when sessions complete.

## Getting Started
1. Clone the repository
2. Install dependencies in both `client/` and `server/`
3. Set up environment variables:
   - Copy `server/env.example` to `server/.env`
   - Update the values with your configuration
4. Start the backend and frontend servers

## Security
- Environment variables (`.env` files) are automatically ignored by Git
- Sensitive data like JWT secrets and database credentials are protected
- Never commit `.env` files to version control
- Test scripts with credentials are excluded from version control
- Use `test-api-template.sh` as a starting point for your own test scripts

## CI/CD Pipeline
This project includes comprehensive GitHub Actions workflows for:
- **Automated Testing**: Frontend, backend, and API integration tests
- **Security Scanning**: Dependency vulnerabilities, code analysis, and secret detection
- **Deployment**: Support for Heroku, Vercel, Netlify, and Docker deployments
- **Quality Assurance**: Linting, building, and automated quality checks

See `.github/README.md` for detailed setup and usage instructions.

---

This project demonstrates modern full-stack development with a focus on productivity, user experience, and maintainable code. Ideal for showcasing skills in React, Node.js, MongoDB, and UI/UX best practices.
