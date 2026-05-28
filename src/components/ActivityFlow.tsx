import React, { useState, useEffect } from 'react';
import { ChevronLeft } from 'lucide-react';
import { Activity } from '../lib/activities';
import { HeartMascot, type EmotionState } from './HeartMascot';

interface ActivityFlowProps {
  activity: Activity;
  onBack: () => void;
  onComplete: () => void;
  onSave: (matchPercentage: number) => void;
}

export const ActivityFlow: React.FC<ActivityFlowProps> = ({ activity, onBack, onComplete, onSave }) => {
  const [currentLevel, setCurrentLevel] = useState(0);
  const [tasks, setTasks] = useState<boolean[][]>(activity.levels.map((l) => Array(l.tasks.length).fill(false)));
  const [photos, setPhotos] = useState<(string | null)[]>(activity.levels.map(() => null));
  const [view, setView] = useState<'intro' | 'level' | 'ending'>('intro');
  const [mascotEmotion, setMascotEmotion] = useState<EmotionState>('idle');
  const [mascotComment, setMascotComment] = useState('');
  const [showComment, setShowComment] = useState(false);

  const level = activity.levels[currentLevel];


  // Transition emotions
  useEffect(() => {
    if (view === 'level' && currentLevel === 0) {
      setMascotEmotion('excited');
      displayComment('Adventure awaits!');
    }
  }, [view, currentLevel]);

  const displayComment = (text: string) => {
    setMascotComment(text);
    setShowComment(true);
  };

  const toggleTask = (taskIndex: number) => {
    const newTasks = [...tasks];
    newTasks[currentLevel][taskIndex] = !newTasks[currentLevel][taskIndex];
    setTasks(newTasks);

    // Show emotion feedback
    if (newTasks[currentLevel][taskIndex]) {
      setMascotEmotion('happy');
      displayComment('Nice! 🎯');
    }
  };

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.currentTarget.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (ev) => {
        const newPhotos = [...photos];
        newPhotos[currentLevel] = ev.target?.result as string;
        setPhotos(newPhotos);

        setMascotEmotion('love');
        displayComment('Perfect memory! 📸');
      };
      reader.readAsDataURL(file);
    }
  };

  const goToNextLevel = () => {
    if (currentLevel < activity.levels.length - 1) {
      setMascotEmotion('excited');
      displayComment(`Level ${currentLevel + 2} coming up!`);
      setTimeout(() => {
        setCurrentLevel(currentLevel + 1);
        window.scrollTo(0, 0);
      }, 800);
    } else {
      setMascotEmotion('celebrating');
      displayComment('We did it! 🎉');
      setTimeout(() => {
        setView('ending');
        // Save with 95% match (successful completion)
        onSave(95);
      }, 500);
    }
  };

  const comments = {
    start: [
      'Ready for this? 💪',
      'Let\'s make memories!',
      'Time to shine! ✨',
      'Adventure awaits! 🌟',
    ],
    complete: [
      'You two are amazing! 💕',
      'So much love today! 🥰',
      'Best couple ever! 👑',
      'This is beautiful! 🌸',
    ],
  };

  if (view === 'intro') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white to-gray-50 p-4 md:p-8 flex flex-col">
        <button
          onClick={onBack}
          className="inline-flex items-center gap-2 text-gray-700 hover:text-gray-900 transition-colors mb-4 md:mb-8"
        >
          <ChevronLeft size={20} />
          <span>Back to results</span>
        </button>

        <div className="flex-1 flex flex-col items-center justify-center gap-6 md:gap-8 max-w-2xl mx-auto w-full">
          <HeartMascot emotion="excited" />

          <div
            className="rounded-3xl shadow-2xl p-6 md:p-12 text-center w-full"
            style={{
              background: `linear-gradient(135deg, ${activity.theme.light}, white)`,
              borderColor: activity.theme.primary,
              borderWidth: '2px',
            }}
          >
            <p className="text-xs md:text-sm font-semibold text-gray-600 mb-2 md:mb-3 uppercase tracking-wider">
              {activity.emoji} {activity.subtitle}
            </p>
            <h1 className="text-3xl md:text-5xl font-bold text-gray-900 mb-3 md:mb-4">{activity.name}</h1>
            <p className="text-gray-700 text-sm md:text-lg leading-relaxed mb-6 md:mb-8">{activity.suitFor}</p>

            {activity.oath && (
              <div
                className="p-4 md:p-6 rounded-2xl mb-6 md:mb-8 border-l-4"
                style={{
                  backgroundColor: activity.theme.light,
                  borderLeftColor: activity.theme.primary,
                }}
              >
                <p className="italic text-gray-700 text-xs md:text-base leading-relaxed">"{activity.oath}"</p>
              </div>
            )}

            {activity.secret && (
              <div className="p-3 md:p-4 rounded-lg bg-yellow-50 border border-yellow-200 mb-6 md:mb-8">
                <p className="text-xs md:text-sm font-semibold text-gray-900">🤫 Secret to keep in mind:</p>
                <p className="text-xs text-gray-700 mt-1 md:mt-2">{activity.secret}</p>
              </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-3 gap-3 md:gap-4 mb-6 md:mb-8">
              <div className="p-3 md:p-4 bg-white rounded-xl border border-gray-200">
                <p className="text-[10px] md:text-xs text-gray-600 mb-0.5 md:mb-1">Duration</p>
                <p className="text-sm md:text-base font-bold text-gray-900">{activity.duration}</p>
              </div>
              <div className="p-3 md:p-4 bg-white rounded-xl border border-gray-200">
                <p className="text-[10px] md:text-xs text-gray-600 mb-0.5 md:mb-1">Levels</p>
                <p className="text-sm md:text-base font-bold text-gray-900">{activity.levels.length}</p>
              </div>
              <div className="p-3 md:p-4 bg-white rounded-xl border border-gray-200">
                <p className="text-[10px] md:text-xs text-gray-600 mb-0.5 md:mb-1">Check-ins</p>
                <p className="text-sm md:text-base font-bold text-gray-900">{activity.levels.length}</p>
              </div>
            </div>

            <button
              onClick={() => {
                setView('level');
                setMascotEmotion('happy');
                displayComment(comments.start[Math.floor(Math.random() * comments.start.length)]);
              }}
              className="w-full py-3 md:py-4 px-6 md:px-8 rounded-xl font-bold text-white text-sm md:text-lg transition-all duration-300 hover:shadow-xl active:scale-95"
              style={{
                background: `linear-gradient(135deg, ${activity.theme.primary}, ${activity.theme.secondary})`,
                boxShadow: `0 10px 30px ${activity.theme.primary}40`,
              }}
            >
              Begin Journey →
            </button>
          </div>
        </div>

      </div>
    );
  }

  if (view === 'ending') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white to-gray-50 p-4 md:p-8 flex flex-col items-center justify-center">
        <HeartMascot emotion="celebrating" />

        <div className="mt-6 md:mt-8 rounded-3xl shadow-2xl p-6 md:p-12 max-w-2xl w-full text-center">
          <h1 className="text-3xl md:text-5xl font-bold text-gray-900 mb-3 md:mb-4">{activity.ending.title}</h1>
          <p className="text-sm md:text-lg text-gray-700 mb-6 md:mb-8 leading-relaxed">{activity.ending.text}</p>

          <div
            className="p-4 md:p-6 rounded-2xl mb-6 md:mb-8 border-l-4 italic text-xs md:text-base text-gray-700"
            style={{
              backgroundColor: activity.theme.light,
              borderLeftColor: activity.theme.primary,
            }}
          >
            "{activity.ending.quote}"
          </div>

          {/* Photo memories */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-6 md:mb-8">
            {photos.map((photo, idx) => (
              <div key={idx} className="aspect-square rounded-xl overflow-hidden shadow-lg border-2 border-gray-200">
                {photo ? (
                  <img src={photo} alt={`Level ${idx + 1}`} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full bg-gray-100 flex items-center justify-center text-2xl">📷</div>
                )}
              </div>
            ))}
          </div>

          <button
            onClick={onComplete}
            className="w-full py-3 md:py-4 px-6 md:px-8 rounded-xl font-bold text-white text-sm md:text-lg transition-all duration-300 hover:shadow-xl active:scale-95"
            style={{
              background: `linear-gradient(135deg, ${activity.theme.primary}, ${activity.theme.secondary})`,
              boxShadow: `0 10px 30px ${activity.theme.primary}40`,
            }}
          >
            Return Home 🏠
          </button>
        </div>
      </div>
    );
  }

  // Main level view
  return (
    <div className="min-h-screen bg-gradient-to-br from-white to-gray-50 p-4 md:p-8">
      <button
        onClick={onBack}
        className="inline-flex items-center gap-2 text-gray-700 hover:text-gray-900 transition-colors mb-4 md:mb-8"
      >
        <ChevronLeft size={20} />
        <span>Back to activity</span>
      </button>

      <div className="max-w-6xl mx-auto">
        {/* Progress bar */}
        <div className="mb-6 md:mb-8">
          <div className="flex justify-between items-center mb-2">
            <h2 className="font-bold text-gray-900">Level {currentLevel + 1}/{activity.levels.length}</h2>
            <span className="text-sm text-gray-600">{Math.round(((currentLevel + 1) / activity.levels.length) * 100)}%</span>
          </div>
          <div className="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full transition-all duration-500 ease-out"
              style={{
                width: `${((currentLevel + 1) / activity.levels.length) * 100}%`,
                background: `linear-gradient(90deg, ${activity.theme.primary}, ${activity.theme.secondary})`,
              }}
            />
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 lg:gap-8">
          {/* Mascot (Above on mobile, Right on desktop) */}
          <div className="col-span-1 order-1 lg:order-last space-y-6">
            <div className="rounded-2xl shadow-lg p-6 bg-gradient-to-br from-red-50 to-pink-50 border-2 border-rose-200 lg:sticky lg:top-8">
              <HeartMascot emotion={mascotEmotion} comment={mascotComment} showComment={showComment} />
            </div>
          </div>

          {/* Left: Content */}
          <div className="col-span-1 lg:col-span-3 order-2 lg:order-first space-y-6">
            {/* Level card */}
            <div
              className="rounded-2xl shadow-lg p-4 md:p-8 border-2"
              style={{
                borderColor: activity.theme.primary,
                background: `linear-gradient(135deg, ${activity.theme.light}, white)`,
              }}
            >
              <div className="flex items-start justify-between mb-4">
                <div>
                  <p className="text-xs md:text-sm font-semibold text-gray-600 uppercase tracking-wider">Level {level.num}</p>
                  <h3 className="text-xl md:text-3xl font-bold text-gray-900 mt-1">{level.name}</h3>
                  <p className="text-xs md:text-sm text-gray-600 mt-2">⏱ {level.time} • 📍 {level.place}</p>
                </div>
              </div>

              <div className="p-3 md:p-4 rounded-lg bg-white border border-gray-200 my-4 md:my-6">
                <p className="text-gray-700 text-sm md:text-base leading-relaxed">{level.context}</p>
              </div>

              {level.spice && (
                <div className="p-3 md:p-4 rounded-lg bg-amber-50 border border-amber-200 mb-4 md:mb-6">
                  <p className="text-xs md:text-sm font-semibold text-gray-900">✨ Spice it up:</p>
                  <p className="text-xs md:text-sm text-gray-700 mt-1 md:mt-2">{level.spice}</p>
                </div>
              )}

              {/* Tasks */}
              <div className="space-y-3">
                <h4 className="font-bold text-sm md:text-base text-gray-900">📋 Tasks</h4>
                {level.tasks.map((task, idx) => (
                  <button
                    key={idx}
                    onClick={() => toggleTask(idx)}
                    className={`w-full text-left p-3 md:p-4 rounded-lg transition-all duration-200 flex items-start gap-3 ${
                      tasks[currentLevel][idx]
                        ? 'bg-green-50 border-green-300'
                        : 'bg-white border-gray-200 hover:bg-gray-50'
                    } border text-xs md:text-sm`}
                  >
                    <div
                      className={`w-5 h-5 md:w-6 md:h-6 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5 transition-all duration-200 ${
                        tasks[currentLevel][idx]
                          ? 'bg-green-500 text-white'
                          : 'bg-gray-200 text-gray-400'
                      }`}
                    >
                      {tasks[currentLevel][idx] ? '✓' : '○'}
                    </div>
                    <span className={tasks[currentLevel][idx] ? 'line-through text-gray-500' : 'text-gray-700'}>
                      {task}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Photo upload */}
            <div className="rounded-2xl shadow-lg p-4 md:p-8 border-2 border-gray-200">
              <h4 className="font-bold text-sm md:text-base text-gray-900 mb-3 md:mb-4">📸 Check-in Photo</h4>
              <p className="text-xs md:text-sm text-gray-600 mb-3 md:mb-4">{level.photoHint}</p>

              <label className="block cursor-pointer">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handlePhotoUpload}
                  className="hidden"
                />
                <div
                  className={`p-4 md:p-8 rounded-lg border-2 border-dashed transition-all duration-200 text-center ${
                    photos[currentLevel]
                      ? 'border-green-300 bg-green-50'
                      : 'border-gray-300 bg-gray-50 hover:border-gray-400'
                  }`}
                >
                  {photos[currentLevel] ? (
                    <div>
                      <img
                        src={photos[currentLevel]}
                        alt="Uploaded"
                        className="w-full h-48 object-cover rounded-lg mb-4"
                      />
                      <p className="text-xs md:text-sm font-semibold text-green-600">✓ Photo uploaded</p>
                    </div>
                  ) : (
                    <div>
                      <p className="text-2xl mb-2">📷</p>
                      <p className="font-semibold text-xs md:text-sm text-gray-700">Click to upload photo</p>
                      <p className="text-[10px] md:text-xs text-gray-600 mt-1">or drag and drop</p>
                    </div>
                  )}
                </div>
              </label>
            </div>

            {/* Navigation */}
            <button
              onClick={goToNextLevel}
              className="w-full py-3 md:py-4 px-6 md:px-8 rounded-xl font-bold text-white text-sm md:text-lg transition-all duration-300 hover:shadow-xl active:scale-95 group"
              style={{
                background: `linear-gradient(135deg, ${activity.theme.primary}, ${activity.theme.secondary})`,
                boxShadow: `0 10px 30px ${activity.theme.primary}40`,
              }}
            >
              {currentLevel === activity.levels.length - 1 ? '🎉 Complete! →' : `Next Level →`}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
