// manages logic of timer:
// countdown logic, session control, mode switching, statistics data collection
import { useState, useRef, useEffect, useCallback } from "react";

const WORK_DURATION = 25 * 60;
const BREAK_DURATION = 5 * 60;
const LONG_BREAK_DURATION = 15 * 60;
const ROUNDS_BEFORE_LONG_BREAK = 4;

export function usePomodoroTimer(onSessionComplete?: () => void) {
  const [time, setTime] = useState(WORK_DURATION);
  const [mode, setMode] = useState<"work" | "break" | "longBreak">("work");
  const [isRunning, setIsRunning] = useState(false);
  const [startTime, setStartTime] = useState<string>("");
  const [rounds, setRounds] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Start the timer
  const start = useCallback(() => {
    if (!isRunning) {
      setIsRunning(true);
      if (!startTime) {
        setStartTime(new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }));
      }
    }
  }, [isRunning, startTime]);

  // Pause the timer
  const pause = useCallback(() => {
    setIsRunning(false);
  }, []);

  // Reset the timer
  const reset = useCallback(() => {
    setIsRunning(false);
    setTime(WORK_DURATION);
    setMode("work");
    setStartTime("");
    setRounds(0);
  }, []);

  // Timer countdown effect
  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTime((prev) => {
          if (prev > 0) {
            return prev - 1;
          } else {
            // Session complete logic
            if (onSessionComplete) onSessionComplete();

            if (mode === "work") {
              if ((rounds + 1) % ROUNDS_BEFORE_LONG_BREAK === 0) {
                setMode("longBreak");
                setTime(LONG_BREAK_DURATION);
              } else {
                setMode("break");
                setTime(BREAK_DURATION);
              }
              setRounds((r) => r + 1);
            } else {
              setMode("work");
              setTime(WORK_DURATION);
              setStartTime(""); // Reset start time for new work session
            }
            return 0;
          }
        });
      }, 1000);
    } else if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isRunning, mode, rounds, onSessionComplete]);

  return {
    time,
    mode,
    isRunning,
    startTime,
    rounds,
    start,
    pause,
    reset,
  };
}