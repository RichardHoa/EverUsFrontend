import React, { useState, useEffect } from 'react';

export type EmotionState = 'idle' | 'happy' | 'excited' | 'thinking' | 'love' | 'celebrating';

interface HeartMascotProps {
  emotion?: EmotionState;
  comment?: string;
  showComment?: boolean;
}

export const HeartMascot: React.FC<HeartMascotProps> = ({
  emotion = 'idle',
  comment,
  showComment = false,
}) => {
  const [displayComment, setDisplayComment] = useState(showComment);

  useEffect(() => {
    setDisplayComment(showComment);
    if (showComment && comment) {
      const timer = setTimeout(() => setDisplayComment(false), 3000);
      return () => clearTimeout(timer);
    }
  }, [showComment, comment]);

  const getEmotionClass = () => {
    const baseClass = 'relative w-24 h-24 mx-auto transition-all duration-500 ease-out animate-sway-bounce';
    switch (emotion) {
      case 'excited':
        return `${baseClass} scale-110 animate-pulse`;
      case 'happy':
        return `${baseClass} scale-105`;
      case 'love':
        return `${baseClass} scale-125`;
      case 'thinking':
        return `${baseClass} opacity-75`;
      case 'celebrating':
        return `${baseClass} scale-110`;
      default:
        return `${baseClass}`;
    }
  };

  const getEyeExpression = () => {
    switch (emotion) {
      case 'excited':
        return { left: 'O', right: 'O' };
      case 'happy':
        return { left: '◠', right: '◠' };
      case 'love':
        return { left: '♥', right: '♥' };
      case 'thinking':
        return { left: '?', right: '.' };
      case 'celebrating':
        return { left: '★', right: '★' };
      default:
        return { left: '○', right: '○' };
    }
  };

  const getMouth = () => {
    switch (emotion) {
      case 'happy':
      case 'excited':
      case 'celebrating':
        return '︶';
      case 'thinking':
        return '◡';
      case 'love':
        return '⌣';
      default:
        return '─';
    }
  };

  const eyes = getEyeExpression();

  return (
    <div className="flex flex-col items-center gap-4">
      <div className={getEmotionClass()}>
        {/* Heart body */}
        <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-lg">
          <path
            d="M50,95 C20,75 5,60 5,45 C5,30 15,20 25,20 C35,20 45,28 50,35 C55,28 65,20 75,20 C85,20 95,30 95,45 C95,60 80,75 50,95 Z"
            fill="currentColor"
            className="text-red-400"
          />
        </svg>

        {/* Face */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          {/* Eyes */}
          <div className="flex gap-3 mb-1">
            <span className="text-lg font-bold text-white">{eyes.left}</span>
            <span className="text-lg font-bold text-white">{eyes.right}</span>
          </div>
          {/* Mouth */}
          <span className="text-xl text-white">{getMouth()}</span>
        </div>

        {/* Stick legs with kicking animation */}
        <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-full">
          <div className="flex gap-3">
            <div className="w-1 h-6 bg-red-400 rounded-full origin-top animate-leg-kick" style={{ animationDelay: '0s' }} />
            <div className="w-1 h-6 bg-red-400 rounded-full origin-top animate-leg-kick" style={{ animationDelay: '0.3s' }} />
          </div>
        </div>

        {/* Stick arms */}
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-full h-full">
          <div className="absolute left-0 top-1/3 w-8 h-1 bg-red-400 origin-right transform -rotate-12" />
          <div className="absolute right-0 top-1/3 w-8 h-1 bg-red-400 origin-left transform rotate-12" />
        </div>
      </div>

      {/* Comment bubble */}
      {displayComment && comment && (
        <div className="animate-fade-in-out text-center">
          <div className="bg-white rounded-lg px-4 py-2 shadow-lg border-2 border-red-200 relative inline-block">
            <p className="text-sm font-semibold text-gray-700 whitespace-nowrap">{comment}</p>
            <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-l-transparent border-r-transparent border-t-white" />
          </div>
        </div>
      )}

      <style>{`
        @keyframes fade-in-out {
          0% { opacity: 0; transform: translateY(-10px); }
          10% { opacity: 1; transform: translateY(0); }
          90% { opacity: 1; transform: translateY(0); }
          100% { opacity: 0; transform: translateY(-10px); }
        }
        .animate-fade-in-out {
          animation: fade-in-out 3s ease-in-out forwards;
        }
      `}</style>
    </div>
  );
};
