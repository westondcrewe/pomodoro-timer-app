import React, { useState } from 'react'
import Timer from './components/Timer.tsx'
import { usePomodoroTimer } from './hooks/usePomodoroTimer.ts'
import './App.css'

const {
  time,
  mode,
  isRunning,
  startTime,
  rounds,
  start,
  pause,
  reset,
} = usePomodoroTimer();

function handleStartSession() {
  if (!startTimeSetRef.current) {
    const now = new Date();
    const formatted = now.toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit',
    });
    setStartTime(formatted);
    startTimeSetRef.current = true;
  }

  // Continue with starting the timer, setting mode, etc.
  setIsRunning(true);
}

function handleReset() {
  setIsRunning(false);
  setTime(defaultWorkDuration);
  setStartTime('');
  startTimeSetRef.current = false;
  setRounds(0);
}

function App() {
  const [mode, setMode] = useState<'work' | 'break'>('work');
  const startTimeSetRef = useRef(false);
  const [startTime, setStartTime] = useState(new Date().toLocaleTimeString());
  const [rounds, setRounds] = useState(0);
  const [time, setTime] = useState(25 * 60);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-red-100 via-blue-100 to-green-100 transition-colors duration-1000">

      {/* Top Bank Row */}
      <div className="flex gap-6 mb-8">
        <Bank label="Start Time" value={startTime} />
        <Bank label="Rounds" value={String(rounds)} />
      </div>

      {/* Timer in center */}
      <div className="relative mb-10">
        {/* Circular progress bar will wrap around this later */}
        <div className="bg-white/80 rounded-xl px-12 py-6 shadow-lg backdrop-blur-md">
          <Timer time={time} mode={mode} />
        </div>
      </div>

      {/* Bottom Button Row */}
      <div className="flex gap-6">
        <Button onClick={() => {}} variant="primary">
          Start {mode === 'work' ? 'Work' : 'Break'}
        </Button>
        <Button onClick={() => {}} variant="secondary">
          Stop
        </Button>
        <Button onClick={() => {}} variant="danger">
          Reset
        </Button>
      </div>
    </div>
  );
}

export default App
