import React from "react";

interface BankProps {
  label: String;
  value: String;
}

const Bank = ({ label, value }: BankProps) => {
  return (
    <div className="bg-white/90 rounded-lg shadow-md px-6 py-3 text-center min-w-[120px]">
      <div className="text-sm font-medium text-gray-500">{label}</div>
      <div className="text-xl font-semibold text-gray-800">{value}</div>
    </div>
  );
};

export default Bank;
