import { useState } from 'react';
import { ACTIVITIES } from './lib/activities';
import { PreferenceMatcher } from './components/PreferenceMatcher';
import { ResultsDashboard } from './components/ResultsDashboard';
import { ActivityFlow } from './components/ActivityFlow';

type PageType = 'matcher' | 'results' | 'activity';

interface MatcherResult {
  ranked: Array<{ key: string; score: number; pct: number }>;
  userVectorP1: number[];
  userVectorP2: number[] | null;
  topActivity: any;
  matchPercentage: number;
}

export default function App() {
  const [currentPage, setCurrentPage] = useState<PageType>('matcher');
  const [result, setResult] = useState<MatcherResult | null>(null);
  const [selectedActivityKey, setSelectedActivityKey] = useState<string | null>(null);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const handleMatch = (preferences: any) => {
    const p1 = [preferences.romance, preferences.adventure, preferences.creative, preferences.indoor, preferences.energy];
    const p2 = preferences.isCouple
      ? [preferences.romance2, preferences.adventure2, preferences.creative2, preferences.indoor2, preferences.energy2]
      : null;

    // Calculate scores for each activity
    const scores = Object.entries(ACTIVITIES).map(([key, activity]) => {
      const v1 = p1;
      const a = activity.vec;

      // Euclidean distance: ||Ax - v||²
      let distance = Math.sqrt(v1.reduce((sum, v, i) => sum + Math.pow(v - a[i], 2), 0));

      // If couple mode: average distance to both vectors
      if (p2) {
        const v2 = p2;
        const distance2 = Math.sqrt(v2.reduce((sum, v, i) => sum + Math.pow(v - a[i], 2), 0));
        distance = (distance + distance2) / 2;
      }

      // Invert to score (lower distance = higher score)
      const score = 100 - distance * 10;
      return { key, score, distance };
    });

    scores.sort((a, b) => b.score - a.score);
    const maxScore = scores[0].score;
    const minScore = scores[scores.length - 1].score;
    const range = maxScore - minScore || 1;

    const ranked = scores.map((s) => ({
      key: s.key,
      score: s.score,
      pct: Math.round(((s.score - minScore) / range) * 100),
    }));

    const topActivityKey = ranked[0].key;
    const topActivity = ACTIVITIES[topActivityKey];
    const topMatch = ranked[0];

    setResult({
      ranked,
      userVectorP1: p1,
      userVectorP2: p2,
      topActivity,
      matchPercentage: topMatch.pct,
    });

    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentPage('results');
      setIsTransitioning(false);
    }, 600);
  };

  const handleBackToMatcher = () => {
    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentPage('matcher');
      setIsTransitioning(false);
    }, 600);
  };

  const handleStartActivity = (activityKey: string) => {
    setSelectedActivityKey(activityKey);
    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentPage('activity');
      setIsTransitioning(false);
    }, 600);
  };

  const handleBackToResults = () => {
    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentPage('results');
      setIsTransitioning(false);
    }, 600);
  };

  return (
    <div className="min-h-screen transition-opacity duration-700" style={{ opacity: isTransitioning ? 0.6 : 1 }}>
      {currentPage === 'matcher' && (
        <div className="animate-fade-in">
          <PreferenceMatcher onMatch={handleMatch} />
        </div>
      )}

      {currentPage === 'results' && result && (
        <div className="animate-fade-in">
          <ResultsDashboard
            ranked={result.ranked}
            userVector={result.userVectorP1}
            userVectorP2={result.userVectorP2}
            topActivity={result.topActivity}
            matchPercentage={result.matchPercentage}
            onSelectActivity={() => {}}
            onStart={handleStartActivity}
            onBack={handleBackToMatcher}
          />
        </div>
      )}

      {currentPage === 'activity' && selectedActivityKey && (
        <div className="animate-fade-in">
          <ActivityFlow
            activity={ACTIVITIES[selectedActivityKey]}
            onBack={handleBackToResults}
            onComplete={handleBackToMatcher}
            onSave={() => {}}
          />
        </div>
      )}
    </div>
  );
}
