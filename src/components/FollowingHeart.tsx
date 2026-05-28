import React, { useState, useEffect, useRef } from 'react';

const CUTE_COMMENTS = [
  "You two are adorable! 💕",
  "This is so sweet! 🥰",
  "Love in the air! ✨",
  "Couple goals! 👑",
  "So romantic! 💑",
  "Y'all are cute AF! 😍",
  "Awww, cuties! 🐰",
  "Match made in heaven! 😇",
  "My heart is melting! 🫶",
  "You're perfect together! ✨",
  "Forever vibes! 💕",
  "So in love! 🌹",
];

export const FollowingHeart: React.FC = () => {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [targetPos, setTargetPos] = useState({ x: 0, y: 0 });
  const [comment, setComment] = useState('');
  const [showComment, setShowComment] = useState(false);
  const commentTimerRef = useRef<NodeJS.Timeout>();
  const commentRandomRef = useRef<NodeJS.Timeout>();

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setTargetPos({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  // Smooth following animation
  useEffect(() => {
    const animationFrame = setInterval(() => {
      setPosition((prev) => ({
        x: prev.x + (targetPos.x - prev.x) * 0.08,
        y: prev.y + (targetPos.y - prev.y) * 0.08,
      }));
    }, 30);

    return () => clearInterval(animationFrame);
  }, [targetPos]);

  // Random cute comments
  useEffect(() => {
    const showRandomComment = () => {
      const randomComment = CUTE_COMMENTS[Math.floor(Math.random() * CUTE_COMMENTS.length)];
      setComment(randomComment);
      setShowComment(true);

      if (commentTimerRef.current) clearTimeout(commentTimerRef.current);
      commentTimerRef.current = setTimeout(() => setShowComment(false), 3500);
    };

    if (commentRandomRef.current) clearTimeout(commentRandomRef.current);
    commentRandomRef.current = setTimeout(showRandomComment, 8000 + Math.random() * 8000);

    return () => {
      if (commentRandomRef.current) clearTimeout(commentRandomRef.current);
      if (commentTimerRef.current) clearTimeout(commentTimerRef.current);
    };
  }, [showComment]);

  return (
    <div
      className="fixed pointer-events-none z-50 transition-all duration-75"
      style={{
        left: `${position.x}px`,
        top: `${position.y}px`,
        transform: 'translate(-50%, -50%)',
      }}
    >
      {/* Heart */}
      <div className="relative w-16 h-16 animate-sway-bounce" style={{ animationDuration: '2s' }}>
        <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xl">
          <defs>
            <filter id="heartGlow" x="-50%" y="-50%" width="200%" height="200%">
              <feGaussianBlur stdDeviation="3" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>
          <path
            d="M50,95 C20,75 5,60 5,45 C5,30 15,20 25,20 C35,20 45,28 50,35 C55,28 65,20 75,20 C85,20 95,30 95,45 C95,60 80,75 50,95 Z"
            fill="url(#heartGradient)"
            filter="url(#heartGlow)"
          />
          <defs>
            <linearGradient id="heartGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#ec4899" stopOpacity="1" />
              <stop offset="100%" stopColor="#f43f5e" stopOpacity="1" />
            </linearGradient>
          </defs>
        </svg>

        {/* Face */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <div className="flex gap-2 mb-0.5">
            <span className="text-base font-bold text-white">♥</span>
            <span className="text-base font-bold text-white">♥</span>
          </div>
          <span className="text-lg text-white">︶</span>
        </div>
      </div>

      {/* Comment bubble */}
      {showComment && (
        <div className="absolute top-full mt-2 left-1/2 transform -translate-x-1/2 animate-fade-in-out">
          <div className="bg-white rounded-full px-4 py-2 shadow-lg border-2 border-rose-300 whitespace-nowrap">
            <p className="text-xs font-bold text-rose-600">{comment}</p>
            <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-3 border-r-3 border-b-3 border-l-transparent border-r-transparent border-b-white" />
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
          animation: fade-in-out 3.5s ease-in-out forwards;
        }
      `}</style>
    </div>
  );
};
