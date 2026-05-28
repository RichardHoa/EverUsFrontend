import React, { useState } from 'react';

interface PreferenceMatcherProps {
  onMatch: (preferences: any) => void;
  isLoading?: boolean;
}

export const PreferenceMatcher: React.FC<PreferenceMatcherProps> = ({ onMatch, isLoading = false }) => {
  const [isCouple, setIsCouple] = useState(false);

  // Partner 1
  const [romance, setRomance] = useState(8);
  const [adventure, setAdventure] = useState(5);
  const [creative, setCreative] = useState(6);
  const [indoor, setIndoor] = useState(7);
  const [energy, setEnergy] = useState(5);

  // Partner 2
  const [romance2, setRomance2] = useState(7);
  const [adventure2, setAdventure2] = useState(6);
  const [creative2, setCreative2] = useState(5);
  const [indoor2, setIndoor2] = useState(6);
  const [energy2, setEnergy2] = useState(6);

  const [budgetMin, setBudgetMin] = useState(100000);
  const [budgetMax, setBudgetMax] = useState(700000);
  const [stage, setStage] = useState(1);

  const handleMatch = () => {
    onMatch({
      romance,
      adventure,
      creative,
      indoor,
      energy,
      romance2: isCouple ? romance2 : undefined,
      adventure2: isCouple ? adventure2 : undefined,
      creative2: isCouple ? creative2 : undefined,
      indoor2: isCouple ? indoor2 : undefined,
      energy2: isCouple ? energy2 : undefined,
      budgetMin,
      budgetMax,
      stage,
      isCouple,
    });
  };

  const romanNumerals = ['Ⅰ', 'Ⅱ', 'Ⅲ'];
  const stageLabels = ['Talking', '1–3M', '3–6M', '6M+'];

  const sliderColors: Record<string, { gradient: string; badge: string; text: string }> = {
    romance: {
      gradient: 'from-pink-500 to-rose-500',
      badge: 'bg-gradient-to-br from-pink-500 to-rose-500',
      text: 'text-pink-600',
    },
    adventure: {
      gradient: 'from-blue-500 to-cyan-500',
      badge: 'bg-gradient-to-br from-blue-500 to-cyan-500',
      text: 'text-blue-600',
    },
    creative: {
      gradient: 'from-purple-500 to-violet-500',
      badge: 'bg-gradient-to-br from-purple-500 to-violet-500',
      text: 'text-purple-600',
    },
    indoor: {
      gradient: 'from-green-500 to-emerald-500',
      badge: 'bg-gradient-to-br from-green-500 to-emerald-500',
      text: 'text-green-600',
    },
    energy: {
      gradient: 'from-orange-500 to-amber-500',
      badge: 'bg-gradient-to-br from-orange-500 to-amber-500',
      text: 'text-orange-600',
    },
  };

  const Slider = ({ label, icon, value, setValue, colorKey }: any) => {
    const colors = sliderColors[colorKey] || sliderColors.romance;

    // Extract actual color values from Tailwind classes
    const colorMap: Record<string, { start: string; end: string }> = {
      romance: { start: '#ec4899', end: '#f43f5e' },
      adventure: { start: '#3b82f6', end: '#06b6d4' },
      creative: { start: '#a855f7', end: '#7c3aed' },
      indoor: { start: '#22c55e', end: '#10b981' },
      energy: { start: '#f97316', end: '#fbbf24' },
    };

    const { start, end } = colorMap[colorKey] || colorMap.romance;

    return (
      <div className="space-y-1 md:space-y-2 py-1 md:py-2">
        <div className="flex items-center gap-2 md:gap-3">
          <span className="text-base md:text-lg flex-shrink-0">{icon}</span>
          <span className={`text-xs md:text-xs font-bold ${colors.text}`}>{label}</span>
          <div className="flex-1" />
          <div className={`w-7 h-7 md:w-8 md:h-8 rounded-lg flex items-center justify-center font-bold text-white text-xs md:text-sm flex-shrink-0 ${colors.badge}`}>
            {value}
          </div>
        </div>
        <div className="relative">
          <div className="relative w-full h-2 md:h-3 rounded-lg overflow-hidden">
            {/* Smooth gradient background */}
            <div
              className="absolute top-0 left-0 h-full rounded-lg"
              style={{
                background: `linear-gradient(to right, ${start}, ${end})`,
                width: `${(value / 10) * 100}%`,
              }}
            />
            {/* Unfilled portion */}
            <div
              className="absolute top-0 h-full bg-gray-200 rounded-lg"
              style={{
                left: `${(value / 10) * 100}%`,
                right: 0,
              }}
            />
          </div>

          {/* Input slider (invisible, just for interaction) */}
          <input
            type="range"
            min="1"
            max="10"
            value={value}
            onChange={(e) => setValue(Number(e.target.value))}
            className="absolute top-0 left-0 w-full h-2 md:h-3 rounded-lg appearance-none cursor-pointer opacity-0"
            style={{
              WebkitAppearance: 'slider-horizontal',
              width: '100%',
            }}
          />

          {/* Tick marks with color */}
          <div className="flex justify-between text-xs px-0 mt-1 pointer-events-none">
            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((tick) => {
              const isActive = tick <= value;
              const tickColor = isActive ? (tick <= value / 2 ? start : end) : '#d1d5db';
              return (
                <span
                  key={tick}
                  className="relative flex flex-col items-center"
                  style={{ width: '10%' }}
                >
                  <div
                    className="w-0.5 rounded-full transition-colors"
                    style={{
                      height: '4px',
                      backgroundColor: tickColor,
                    }}
                  />
                </span>
              );
            })}
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-50 via-white to-purple-50 p-3 md:p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header with Gradient Background */}
        <div className="bg-gradient-to-r from-pink-400 via-purple-400 to-blue-400 rounded-2xl md:rounded-3xl p-6 md:p-12 mb-6 md:mb-8 shadow-lg">
          <div className="text-center">
            <h1 className="text-3xl md:text-5xl lg:text-6xl font-bold text-white mb-1 md:mb-2 drop-shadow-lg break-words" style={{ fontFamily: 'Playfair Display, serif' }}>
              EverUs
            </h1>
            <p className="text-xs md:text-sm tracking-widest text-white/90 uppercase drop-shadow">Linear Algebra Couple Recommendation</p>
            <p className="text-xs md:text-base text-white/95 mt-2 md:mt-3 max-w-lg mx-auto drop-shadow leading-relaxed">Tell us your couple's vibe — we'll find your perfect date using advanced vector matching.</p>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 md:gap-8 mb-8">
          {/* Left: Instructions - Hidden on Mobile */}
          <div className="hidden lg:block lg:col-span-3 space-y-4">
            <div className="bg-gradient-to-br from-pink-100 to-pink-50 rounded-2xl p-4 md:p-6 border-2 border-pink-300 backdrop-blur-sm">
              <div className="text-lg md:text-2xl font-bold text-gray-900 mb-3 md:mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
                {romanNumerals[0]} How It Works
              </div>
              <p className="text-xs md:text-sm text-gray-700 leading-relaxed">
                Adjust your couple's preferences across <strong>5 dimensions</strong>. Our math finds the activity that best matches both of you.
              </p>
            </div>

            <div className="bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl p-4 md:p-6 border-2 border-purple-300 backdrop-blur-sm">
              <div className="text-base md:text-lg font-bold text-gray-900 mb-2 md:mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
                {romanNumerals[1]} The Algorithm
              </div>
              <p className="text-xs text-gray-700 font-mono bg-white/60 rounded p-2 md:p-3 mb-2">
                <span className="text-pink-600">x = argmin ||Ax - v||²</span>
              </p>
              <p className="text-xs md:text-sm text-gray-600">
                Least squares projection finds your best match in activity space.
              </p>
            </div>

            <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-4 md:p-6 border-2 border-blue-300 backdrop-blur-sm">
              <div className="text-base md:text-lg font-bold text-gray-900 mb-2 md:mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
                {romanNumerals[2]} Your Results
              </div>
              <p className="text-xs md:text-sm text-gray-700 leading-relaxed">
                Get ranked activities, dimension analysis, and visual match scores.
              </p>
            </div>
          </div>

          {/* Center: Preference Sliders */}
          <div className="lg:col-span-5">
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl md:rounded-3xl shadow-xl p-4 md:p-8 border border-white/60 space-y-4 md:space-y-6">
              <div>
                <h2 className="text-xl md:text-2xl font-bold text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif' }}>
                  Partner Ⅰ
                </h2>
                <p className="text-xs md:text-sm text-gray-600">Adjust your preferences</p>
              </div>

              <div className="space-y-3 md:space-y-4">
                <Slider label="Romance" icon="💕" value={romance} setValue={setRomance} colorKey="romance" />
                <Slider label="Adventure" icon="🧗" value={adventure} setValue={setAdventure} colorKey="adventure" />
                <Slider label="Creativity" icon="🎨" value={creative} setValue={setCreative} colorKey="creative" />
                <Slider label="Indoor" icon="🏠" value={indoor} setValue={setIndoor} colorKey="indoor" />
                <Slider label="Energy" icon="⚡" value={energy} setValue={setEnergy} colorKey="energy" />
              </div>

              {/* Couple Mode Toggle */}
              <div className="pt-3 md:pt-4 border-t border-gray-200">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isCouple}
                    onChange={(e) => setIsCouple(e.target.checked)}
                    className="w-5 h-5 rounded accent-pink-500"
                  />
                  <span className="text-xs md:text-sm font-semibold text-gray-700">Add Partner Ⅱ</span>
                </label>
              </div>

              {/* Partner 2 */}
              {isCouple && (
                <div className="space-y-3 md:space-y-4 pt-4 md:pt-6 border-t border-gray-200">
                  <div>
                    <h3 className="text-lg md:text-xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>
                      Partner Ⅱ
                    </h3>
                  </div>
                  <div className="space-y-3 md:space-y-4">
                    <Slider label="Romance" icon="💕" value={romance2} setValue={setRomance2} colorKey="romance" />
                    <Slider label="Adventure" icon="🧗" value={adventure2} setValue={setAdventure2} colorKey="adventure" />
                    <Slider label="Creativity" icon="🎨" value={creative2} setValue={setCreative2} colorKey="creative" />
                    <Slider label="Indoor" icon="🏠" value={indoor2} setValue={setIndoor2} colorKey="indoor" />
                    <Slider label="Energy" icon="⚡" value={energy2} setValue={setEnergy2} colorKey="energy" />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Right: Budget & Stage */}
          <div className="lg:col-span-4 space-y-4 md:space-y-6">
            {/* Budget */}
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl md:rounded-3xl shadow-xl p-4 md:p-8 border border-white/60">
              <h3 className="text-base md:text-lg font-bold text-gray-900 mb-3 md:mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
                💸 Budget Range
              </h3>
              <div className="space-y-2 md:space-y-3">
                <div>
                  <label className="text-xs font-bold text-gray-600 block mb-2">Minimum (VND)</label>
                  <input
                    type="number"
                    value={budgetMin}
                    onChange={(e) => setBudgetMin(Number(e.target.value))}
                    className="w-full px-3 md:px-4 py-2 md:py-3 rounded-lg border-2 border-gray-200 focus:border-pink-500 focus:outline-none font-semibold text-gray-900 text-sm"
                  />
                </div>
                <div>
                  <label className="text-xs font-bold text-gray-600 block mb-2">Maximum (VND)</label>
                  <input
                    type="number"
                    value={budgetMax}
                    onChange={(e) => setBudgetMax(Number(e.target.value))}
                    className="w-full px-3 md:px-4 py-2 md:py-3 rounded-lg border-2 border-gray-200 focus:border-pink-500 focus:outline-none font-semibold text-gray-900 text-sm"
                  />
                </div>
              </div>
            </div>

            {/* Relationship Stage */}
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl md:rounded-3xl shadow-xl p-4 md:p-8 border border-white/60">
              <h3 className="text-base md:text-lg font-bold text-gray-900 mb-3 md:mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
                💑 Relationship Stage
              </h3>
              <div className="grid grid-cols-2 gap-2">
                {stageLabels.map((label, idx) => (
                  <button
                    key={idx}
                    onClick={() => setStage(idx)}
                    className={`py-2 md:py-3 px-2 md:px-3 rounded-lg font-semibold text-xs transition-all ${
                      stage === idx
                        ? 'bg-gradient-to-r from-pink-500 to-rose-500 text-white shadow-lg'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            {/* CTA */}
            <button
              onClick={handleMatch}
              disabled={isLoading}
              className="w-full py-3 md:py-4 rounded-lg md:rounded-xl font-bold text-white transition-all duration-300 hover:shadow-xl active:scale-95 bg-gradient-to-r from-pink-500 to-rose-500 disabled:opacity-50 disabled:cursor-not-allowed text-sm md:text-lg"
            >
              {isLoading ? 'Finding Your Match...' : '✨ Find Our Perfect Date'}
            </button>

            {/* Info */}
            <div className="text-center text-xs text-gray-600 leading-relaxed">
              <p>
                <strong>Couple Mode:</strong> We'll find the activity that best matches <em>both</em> of your preferences using least squares minimization.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
