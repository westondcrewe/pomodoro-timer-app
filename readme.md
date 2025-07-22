# Pomodoro Timer App

## Overview
The Pomodoro Timer App is a full-stack productivity tool designed to help users manage their work and break intervals using the Pomodoro Technique. The application enables users to track their worktime management habits, visualize session statistics, and build better focus routines.

## Tech Stack
- **Frontend:** React (with Vite for fast development), TailwindCSS for modern, responsive UI
- **Backend:** Node.js with Express.js (MERN stack)
- **Database:** MongoDB for persistent storage of user work session data and statistics
- **Other:** TypeScript (for type safety), custom React hooks, modular component architecture

## Features
- Interactive Pomodoro timer with work, short break, and long break cycles
- Session and round tracking
- Responsive, accessible UI with a custom color palette (TailwindCSS)
- System notifications and optional sound alerts for background operation
- Persistent user data and statistics (worktime management habits) stored in MongoDB
- Clean separation of frontend and backend codebases

## Project Structure
```
pomodoro-timer-app/
  client/    # React frontend (Vite, TailwindCSS)
  server/    # Node.js/Express backend (API, MongoDB)
```

## How It Works
- The frontend provides a single-page application for timer control, session display, and statistics.
- The backend exposes RESTful APIs for user data and session tracking, connecting to a MongoDB database.
- Users can run the timer in the background and receive notifications when sessions complete.

## Getting Started
1. Clone the repository
2. Install dependencies in both `client/` and `server/`
3. Start the backend and frontend servers

---

This project demonstrates modern full-stack development with a focus on productivity, user experience, and maintainable code. Ideal for showcasing skills in React, Node.js, MongoDB, and UI/UX best practices.
