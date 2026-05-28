import React, { useState } from 'react';
import { DIMENSIONS } from '../lib/activities';

interface SpiderGraphProps {
  userVector: number[];
  activityVector: number[];
  activityTheme: {
    primary: string;
    secondary: string;
    accent: string;
  };
  className?: string;
}

export const SpiderGraph: React.FC<SpiderGraphProps> = ({
  userVector,
  activityVector,
  activityTheme,
  className = '',
}) => {
  const [hoveredDimension, setHoveredDimension] = useState<number | null>(null);

  // Responsive sizing - smaller on mobile
  const isMobile = window.innerWidth < 768;
  const size = isMobile ? 280 : 400;
  const center = size / 2;
  const maxRadius = isMobile ? 90 : 140;
  const numDimensions = 5;
  const angleSlice = (Math.PI * 2) / numDimensions;

  // Convert scale 1-10 to 0-1
  const normalizeValue = (val: number) => Math.max(0, Math.min(val / 10, 1));

  const getCoordinates = (dimension: number, value: number) => {
    const angle = angleSlice * dimension - Math.PI / 2;
    const radius = normalizeValue(value) * maxRadius;
    const x = center + radius * Math.cos(angle);
    const y = center + radius * Math.sin(angle);
    return { x, y };
  };

  // Build polygon path
  const activityPath = Array.from({ length: numDimensions })
    .map((_, i) => getCoordinates(i, activityVector[i]))
    .map(({ x, y }, i) => (i === 0 ? `M ${x} ${y}` : `L ${x} ${y}`))
    .join(' ') + ' Z';

  const userPath = Array.from({ length: numDimensions })
    .map((_, i) => getCoordinates(i, userVector[i]))
    .map(({ x, y }, i) => (i === 0 ? `M ${x} ${y}` : `L ${x} ${y}`))
    .join(' ') + ' Z';

  // Reference path (ideal)
  const idealPath = Array.from({ length: numDimensions })
    .map((_, i) => getCoordinates(i, 10))
    .map(({ x, y }, i) => (i === 0 ? `M ${x} ${y}` : `L ${x} ${y}`))
    .join(' ') + ' Z';

  return (
    <div className={`flex flex-col gap-3 md:gap-4 ${className}`}>
      <div className="bg-white rounded-lg md:rounded-xl shadow-lg p-3 md:p-6 border border-gray-100">
        {/* Header */}
        <div className="mb-3 md:mb-6">
          <h3 className="text-base md:text-lg font-bold text-gray-900 mb-1">Activity Match Analysis</h3>
          <p className="text-xs md:text-sm text-gray-500">Ideal vs Activity vs Your Preferences</p>
        </div>

        {/* SVG Graph */}
        <div className="flex justify-center mb-3 md:mb-6">
          <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="drop-shadow-md max-w-full h-auto">
            <defs>
              <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="2" result="coloredBlur" />
                <feMerge>
                  <feMergeNode in="coloredBlur" />
                  <feMergeNode in="SourceGraphic" />
                </feMerge>
              </filter>
              <linearGradient id="activityGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor={activityTheme.primary} stopOpacity="0.6" />
                <stop offset="100%" stopColor={activityTheme.accent} stopOpacity="0.8" />
              </linearGradient>
              <linearGradient id="userGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#EC4899" stopOpacity="0.5" />
                <stop offset="100%" stopColor="#F43F5E" stopOpacity="0.7" />
              </linearGradient>
            </defs>

            {/* Grid circles */}
            {[0.2, 0.4, 0.6, 0.8, 1.0].map((scale) => (
              <circle
                key={`grid-${scale}`}
                cx={center}
                cy={center}
                r={maxRadius * scale}
                fill="none"
                stroke="#e5e7eb"
                strokeWidth="0.5"
                strokeDasharray="2,2"
              />
            ))}

            {/* Axis lines */}
            {Array.from({ length: numDimensions }).map((_, i) => {
              const { x, y } = getCoordinates(i, 10);
              return (
                <line
                  key={`axis-${i}`}
                  x1={center}
                  y1={center}
                  x2={x}
                  y2={y}
                  stroke="#d1d5db"
                  strokeWidth="1"
                  opacity="0.5"
                />
              );
            })}

            {/* Ideal (reference) polygon - very light */}
            <path d={idealPath} fill="none" stroke="#fbbf24" strokeWidth="2" opacity="0.3" strokeDasharray="4,4" />

            {/* Activity polygon */}
            <path
              d={activityPath}
              fill="url(#activityGrad)"
              stroke={activityTheme.primary}
              strokeWidth="2.5"
              filter="url(#glow)"
              className="transition-all duration-300"
              opacity={hoveredDimension === null ? 1 : 0.6}
            />

            {/* User polygon */}
            <path
              d={userPath}
              fill="url(#userGrad)"
              stroke="#ec4899"
              strokeWidth="2"
              opacity={hoveredDimension === null ? 0.7 : 0.4}
              className="transition-all duration-300"
            />

            {/* Interactive dots and labels */}
            {Array.from({ length: numDimensions }).map((_, i) => {
              const actCoords = getCoordinates(i, activityVector[i]);
              const userCoords = getCoordinates(i, userVector[i]);

              return (
                <g key={`dimension-${i}`}>
                  {/* Activity dot */}
                  <circle
                    cx={actCoords.x}
                    cy={actCoords.y}
                    r="5"
                    fill={activityTheme.primary}
                    opacity={hoveredDimension === i ? 1 : 0.7}
                    className="transition-all duration-200 cursor-pointer hover:r-7"
                    onMouseEnter={() => setHoveredDimension(i)}
                    onMouseLeave={() => setHoveredDimension(null)}
                  />

                  {/* User dot */}
                  <circle
                    cx={userCoords.x}
                    cy={userCoords.y}
                    r="4"
                    fill="#ec4899"
                    opacity={hoveredDimension === i ? 1 : 0.5}
                    className="transition-all duration-200 cursor-pointer"
                    onMouseEnter={() => setHoveredDimension(i)}
                    onMouseLeave={() => setHoveredDimension(null)}
                  />

                  {/* Label */}
                  <g
                    onMouseEnter={() => setHoveredDimension(i)}
                    onMouseLeave={() => setHoveredDimension(null)}
                    className="cursor-pointer"
                  >
                    <text
                      x={center + (maxRadius + (isMobile ? 15 : 25)) * Math.cos(angleSlice * i - Math.PI / 2)}
                      y={center + (maxRadius + (isMobile ? 15 : 25)) * Math.sin(angleSlice * i - Math.PI / 2)}
                      textAnchor="middle"
                      dominantBaseline="middle"
                      className="text-xs font-semibold transition-all duration-200"
                      fill={hoveredDimension === i ? activityTheme.primary : '#6b7280'}
                      fontSize={isMobile ? '10' : '12'}
                    >
                      {DIMENSIONS[i].icon}
                    </text>
                  </g>
                </g>
              );
            })}
          </svg>
        </div>

        {/* Legend */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-2 md:gap-4 mt-3 md:mt-6 p-3 md:p-4 rounded-lg bg-gray-50 border border-gray-200">
          <div className="flex items-center gap-2 md:gap-3">
            <svg width="20" height="20" viewBox="0 0 24 24">
              <polygon points="12,4 20,8 20,16 12,20 4,16 4,8" fill={activityTheme.primary} opacity="0.6" stroke={activityTheme.primary} strokeWidth="2" />
            </svg>
            <div>
              <p className="text-xs font-bold text-gray-900">Activity Vector</p>
              <p className="text-xs text-gray-600">What you get</p>
            </div>
          </div>

          <div className="flex items-center gap-2 md:gap-3">
            <svg width="20" height="20" viewBox="0 0 24 24">
              <polygon points="12,4 20,8 20,16 12,20 4,16 4,8" fill="#ec4899" opacity="0.4" stroke="#ec4899" strokeWidth="2" />
            </svg>
            <div>
              <p className="text-xs font-bold text-gray-900">Your Preference</p>
              <p className="text-xs text-gray-600">What you want</p>
            </div>
          </div>

          <div className="flex items-center gap-2 md:gap-3">
            <svg width="20" height="20" viewBox="0 0 24 24">
              <polygon points="12,4 20,8 20,16 12,20 4,16 4,8" fill="none" stroke="#fbbf24" strokeWidth="2" strokeDasharray="4,2" />
            </svg>
            <div>
              <p className="text-xs font-bold text-gray-900">Ideal Match</p>
              <p className="text-xs text-gray-600">Perfect 10/10</p>
            </div>
          </div>
        </div>

        {/* Hover explanation */}
        <p className="text-xs text-gray-500 text-center mt-2 md:mt-4">Hover over dimensions to see alignment percentage</p>

        {/* Dimension Details */}
        {hoveredDimension !== null && (
          <div className="mt-3 md:mt-6 p-3 md:p-4 rounded-lg bg-gradient-to-r from-gray-50 to-white border border-gray-200 animate-fade-in">
            <p className="text-xs md:text-sm font-semibold text-gray-900 mb-2">
              {DIMENSIONS[hoveredDimension].icon} {DIMENSIONS[hoveredDimension].label}
            </p>
            <div className="flex gap-3 md:gap-4 text-xs">
              <div>
                <p className="text-gray-500">Activity</p>
                <p className="font-bold text-gray-900">{activityVector[hoveredDimension]}/10</p>
              </div>
              <div>
                <p className="text-gray-500">Your Preference</p>
                <p className="font-bold text-gray-900">{userVector[hoveredDimension]}/10</p>
              </div>
              <div>
                <p className="text-gray-500">Alignment</p>
                <p className="font-bold text-emerald-600">
                  {Math.round((1 - Math.abs(activityVector[hoveredDimension] - userVector[hoveredDimension]) / 10) * 100)}%
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(-8px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-fade-in {
          animation: fade-in 0.3s ease-out;
        }
      `}</style>
    </div>
  );
};
