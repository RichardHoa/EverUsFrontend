import React, { useState } from 'react';
import { Activity, ACTIVITIES, DIMENSIONS } from '../lib/activities';
import { SpiderGraph } from './SpiderGraph';

interface RankedActivity {
  key: string;
  score: number;
  pct: number;
}

interface ResultsDashboardProps {
  ranked: RankedActivity[];
  userVector: number[];
  userVectorP2?: number[] | null;
  topActivity: Activity;
  matchPercentage: number;
  onSelectActivity: (key: string) => void;
  onStart: (key: string) => void;
  onBack: () => void;
}

export const ResultsDashboard: React.FC<ResultsDashboardProps> = ({
  ranked,
  userVector,
  userVectorP2: _userVectorP2,
  topActivity,
  matchPercentage,
  onSelectActivity,
  onStart,
  onBack,
}) => {
  const [selectedKey, setSelectedKey] = useState(topActivity.key);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const selectedActivity = ACTIVITIES[selectedKey] || topActivity;

  const handleSelectActivity = (key: string) => {
    setIsTransitioning(true);
    setTimeout(() => {
      setSelectedKey(key);
      onSelectActivity(key);
      setIsTransitioning(false);
    }, 400);
  };

  // Dimension bars with animations
  const DimensionBar: React.FC<{ dimIndex: number; activity: Activity }> = ({ dimIndex, activity }) => {
    const dim = DIMENSIONS[dimIndex];
    const activityVal = activity.vec[dimIndex];
    const userVal = userVector[dimIndex];

    return (
      <div className="flex items-center gap-2 py-1.5">
        <span className="text-sm">{dim.icon}</span>
        <span className="text-xs font-semibold text-gray-600 w-20 flex-shrink-0">{dim.label}</span>
        <div className="flex-1">
          <div className="h-5 bg-gray-100 rounded-full overflow-hidden relative">
            {/* User bar - lighter, behind */}
            <div
              className="absolute h-full opacity-40 transition-all duration-700 ease-out"
              style={{
                width: `${(userVal / 10) * 100}%`,
                background: 'linear-gradient(90deg, #ec4899, #f43f5e)',
              }}
            />
            {/* Activity bar - on top */}
            <div
              className="h-full transition-all duration-700 ease-out"
              style={{
                width: `${(activityVal / 10) * 100}%`,
                background: `linear-gradient(90deg, ${selectedActivity.theme.secondary}, ${selectedActivity.theme.primary})`,
              }}
            />
          </div>
        </div>
        <span className="text-xs font-bold text-gray-700 w-6 text-right">{activityVal}</span>
      </div>
    );
  };

  return (
    <div className={`flex flex-col gap-8 h-full transition-opacity duration-700 ${isTransitioning ? 'opacity-50' : 'opacity-100'}`}>
      {/* Back button */}
      <button
        onClick={onBack}
        className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 font-semibold mt-4 ml-4 transition"
      >
        ← Back to Preferences
      </button>

      {/* Main result card */}
      <div className="px-4">
        <div
          className="rounded-2xl shadow-xl border overflow-hidden transition-all duration-500 animate-glow-wave"
          style={{
            borderColor: selectedActivity.theme.primary,
            background: `linear-gradient(135deg, ${selectedActivity.theme.light} 0%, white 100%)`,
            boxShadow: `0 0 20px ${selectedActivity.theme.primary}40, inset 0 0 10px ${selectedActivity.theme.primary}10`,
          }}
        >
          {/* Gradient header */}
          <div
            className="px-8 py-6 text-white"
            style={{ background: `linear-gradient(135deg, ${selectedActivity.theme.primary}, ${selectedActivity.theme.secondary})` }}
          >
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-semibold opacity-90 mb-2">{selectedActivity.subtitle}</p>
                <h1 className="text-4xl font-bold">{selectedActivity.emoji}</h1>
                <h2 className="text-3xl font-bold mt-2">{selectedActivity.name}</h2>
              </div>
              <div className="text-right">
                <p className="text-sm opacity-90 mb-2">Match Score</p>
                <div
                  className="w-24 h-24 rounded-full flex items-center justify-center font-bold text-white shadow-lg"
                  style={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', backdropFilter: 'blur(10px)' }}
                >
                  <span className="text-3xl">{matchPercentage}%</span>
                </div>
              </div>
            </div>
          </div>

          {/* Content */}
          <div className="px-8 py-6 space-y-4">
            <p className="text-gray-700 text-sm leading-relaxed">{selectedActivity.suitFor}</p>

            <div className="grid grid-cols-2 gap-4 text-center text-xs">
              <div className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                <p className="text-gray-600 mb-1">Budget</p>
                <p className="font-bold text-gray-900">{selectedActivity.cost.toLocaleString('vi-VN')} VND</p>
              </div>
              <div className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                <p className="text-gray-600 mb-1">Levels</p>
                <p className="font-bold text-gray-900">{selectedActivity.levels.length} activities</p>
              </div>
            </div>

            <button
              onClick={() => onStart(selectedKey)}
              className="w-full py-4 rounded-xl font-bold text-white transition-all duration-300 hover:shadow-xl active:scale-95"
              style={{
                background: `linear-gradient(135deg, ${selectedActivity.theme.primary}, ${selectedActivity.theme.secondary})`,
                boxShadow: `0 8px 20px ${selectedActivity.theme.primary}40`,
              }}
            >
              Let's Start! →
            </button>
          </div>
        </div>
      </div>

      {/* Main Grid: Left (Preferences + Matches) + Right (Spider Graph) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 animate-fade-in px-4">
        {/* Left Column: Stacked Preferences + All Matches */}
        <div className="lg:col-span-1 space-y-6">
          {/* Preferences Card */}
          <div className="bg-gradient-to-br from-white/70 to-pink-50/50 backdrop-blur-sm rounded-2xl shadow-lg p-6 border border-white/60">
            <h3 className="font-bold text-gray-900 mb-3 text-sm">Your Preferences (v)</h3>
            <div className="space-y-2">
              {Array.from({ length: 5 }).map((_, i) => (
                <DimensionBar key={i} dimIndex={i} activity={{ ...selectedActivity, vec: userVector as [number, number, number, number, number] }} />
              ))}
            </div>
          </div>

          {/* All Matches Card */}
          <div className="bg-gradient-to-br from-white/70 to-purple-50/50 backdrop-blur-sm rounded-2xl shadow-lg p-6 border border-white/60">
            <h3 className="font-bold text-gray-900 mb-4 text-sm">All Activities (6 Total)</h3>
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {ranked.map((r) => {
                const act = ACTIVITIES[r.key];
                const isSelected = r.key === selectedKey;

                return (
                  <button
                    key={r.key}
                    onClick={() => handleSelectActivity(r.key)}
                    className={`w-full text-left p-3 rounded-lg transition-all duration-200 border text-xs ${
                      isSelected
                        ? 'bg-gradient-to-r shadow-md'
                        : 'bg-gray-50 border-gray-200 hover:bg-gray-100'
                    }`}
                    style={
                      isSelected
                        ? {
                            background: `linear-gradient(135deg, ${act.theme.light}, white)`,
                            borderColor: act.theme.primary,
                          }
                        : {}
                    }
                  >
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex items-center gap-2 flex-1 min-w-0">
                        <span className="text-lg">{act.emoji}</span>
                        <div className="min-w-0">
                          <p className="font-bold text-gray-900 truncate">{act.name}</p>
                          <p className="text-xs text-gray-600">{act.duration}</p>
                        </div>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <p className="font-bold text-lg" style={{ color: act.theme.primary }}>
                          {r.pct}%
                        </p>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Right Column: Bigger Spider Graph with Better Legend */}
        <div className="lg:col-span-2">
          <div className="bg-gradient-to-br from-white/70 to-blue-50/50 backdrop-blur-sm rounded-2xl shadow-lg p-8 border border-white/60 h-full">
            <h3 className="font-bold text-gray-900 mb-6 text-base">Activity Match Analysis</h3>
            <div className="flex flex-col gap-6">
              {/* Bigger Spider Graph */}
              <div className="flex-1 min-h-96">
                <SpiderGraph
                  userVector={userVector}
                  activityVector={selectedActivity.vec}
                  activityTheme={selectedActivity.theme}
                />
              </div>

              {/* Enhanced Legend with Colors and Text */}
              <div className="border-t pt-6">
                <h4 className="text-xs font-bold text-gray-700 mb-4 uppercase tracking-widest">Dimension Breakdown</h4>
                <div className="grid grid-cols-2 gap-4">
                  <div className="flex items-start gap-3">
                    <div className="w-4 h-4 rounded mt-0.5 bg-gradient-to-br from-pink-500 to-rose-500 flex-shrink-0" />
                    <div>
                      <p className="font-bold text-sm text-pink-700">Romance</p>
                      <p className="text-xs text-gray-600">Emotional connection</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-4 h-4 rounded mt-0.5 bg-gradient-to-br from-blue-500 to-cyan-500 flex-shrink-0" />
                    <div>
                      <p className="font-bold text-sm text-blue-700">Adventure</p>
                      <p className="text-xs text-gray-600">Energy & exploration</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-4 h-4 rounded mt-0.5 bg-gradient-to-br from-purple-500 to-violet-500 flex-shrink-0" />
                    <div>
                      <p className="font-bold text-sm text-purple-700">Creativity</p>
                      <p className="text-xs text-gray-600">Originality & ideas</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-4 h-4 rounded mt-0.5 bg-gradient-to-br from-green-500 to-emerald-500 flex-shrink-0" />
                    <div>
                      <p className="font-bold text-sm text-green-700">Indoor</p>
                      <p className="text-xs text-gray-600">Comfort & coziness</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3 col-span-2">
                    <div className="w-4 h-4 rounded mt-0.5 bg-gradient-to-br from-orange-500 to-amber-500 flex-shrink-0" />
                    <div>
                      <p className="font-bold text-sm text-orange-700">Energy</p>
                      <p className="text-xs text-gray-600">Activity level & intensity</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
