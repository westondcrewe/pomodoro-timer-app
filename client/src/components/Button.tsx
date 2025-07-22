import React from 'react'

interface ButtonProps {
  onClick: () => void;
  variant: 'primary' | 'secondary' | 'danger';
  children: React.ReactNode;
}

const Button = ({ onClick, variant, children }: ButtonProps) => {
  return (
    <div
      className={`px-4 py-2 rounded-md ${
        variant === 'primary'
          ? 'bg-blue-500 text-white'
          : variant === 'secondary'
          ? 'bg-gray-200 text-gray-800'
          : 'bg-red-500 text-white'
      }`}
      onClick={onClick}
    >
      {children}
      {variant === 'primary' && <span className="text-white">Start</span>}
      {variant === 'secondary' && <span className="text-gray-800">Stop</span>}
      {variant === 'danger' && <span className="text-white">Reset</span>}
    </div>
  )
}

export default Button
