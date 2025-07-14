import React from 'react';

interface TimerProp {
    time: Number;
    mode: String;
}

const Timer = ({ time, mode }: TimerProp) => {
  const minutes = String(Math.floor(Number(time) / 60)).padStart(2, '0');
  const seconds = String(Number(time) % 60).padStart(2, '0');

  const isWork = mode === 'work';

  return (
    <div className={`w-full max-w-md mx-auto p-6 rounded-xl shadow-lg
      ${isWork ? 'bg-red-100' : 'bg-blue-100'}
      text-center transition-all duration-500 ease-in-out
    `}>
      <h2 className={`text-xl font-semibold tracking-wide mb-2
        ${isWork ? 'text-red-600' : 'text-blue-600'}
      `}>
        {isWork ? 'Work Time' : 'Break Time'}
      </h2>

      <div className="text-6xl font-mono text-gray-800">
        {minutes}:{seconds}
      </div>
    </div>
  );
}

export default Timer