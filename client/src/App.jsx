import React from 'react';
import Timer from './components/Timer.tsx';
import Bank from './components/Bank.tsx';
import Button from './components/Button.tsx';
import { usePomodoroTimer } from './hooks/usePomodoroTimer.ts';
import './App.css';

function App() {
  // Callback for when a session completes
  const handleSessionComplete = () => {
    // Example: play a sound, show a notification, etc.
    if (Notification.permission === "granted") {
      new Notification("Pomodoro Timer", {
        body: "Session complete! Time to switch.",
        // icon: "/path/to/icon.png", // Optional: add your app icon
      });
    }
    // Optionally, play a sound here
    const audio = new Audio("client/src/assets/timer-sound.mp3");
    audio.play();
    console.log("Session complete!");
  };

  // Use the Pomodoro timer hook, passing the session complete callback
  const {
    time,
    mode,
    isRunning,
    startTime,
    rounds,
    start,
    pause,
    reset,
  } = usePomodoroTimer(handleSessionComplete);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-red-100 via-blue-100 to-green-100 transition-colors duration-1000">
      {/* Top Bank Row */}
      <div className="flex gap-6 mb-8">
        <Bank label="Start Time" value={startTime} />
        <Bank label="Rounds" value={String(rounds)} />
      </div>

      {/* Timer in center */}
      <div className="relative mb-10">
        <div className="bg-white/80 rounded-xl px-12 py-6 shadow-lg backdrop-blur-md">
          <Timer time={time} mode={mode} />
        </div>
      </div>

      {/* Bottom Button Row */}
      <div className="flex gap-6">
        <Button onClick={start} variant="primary">
          {mode === 'work' ? 'Work ' : mode === 'break' ? 'Break ' : 'Long Break '}
        </Button>
        <Button onClick={pause} variant="secondary">
        </Button>
        <Button onClick={reset} variant="danger">
        </Button>
      </div>
    </div>
  );
}

export default App;
