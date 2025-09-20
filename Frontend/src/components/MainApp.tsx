import { useState } from "react";
import { Dashboard } from "./Dashboard";
import { InBodySetup } from "./InBodySetup";
import { DietTracker } from "./DietTracker";
import { WorkoutPlanner } from "./WorkoutPlanner";
import { AITrainer } from "./AITrainer";
import { Profile } from "./Profile";
import { BottomNavigation } from "./BottomNavigation";

type Screen = "dashboard" | "inbody" | "diet" | "workout" | "ai" | "profile";

interface MainAppProps {
  user: any;
  onLogout: () => void;
}

export function MainApp({ user, onLogout }: MainAppProps) {
  const [currentScreen, setCurrentScreen] = useState<Screen>("dashboard");
  const [hasCompletedInBody, setHasCompletedInBody] = useState(false);

  // If user hasn't completed InBody setup, show that first
  if (!hasCompletedInBody && currentScreen === "dashboard") {
    return (
      <InBodySetup 
        user={user}
        onComplete={() => setHasCompletedInBody(true)}
      />
    );
  }

  const renderScreen = () => {
    switch (currentScreen) {
      case "dashboard":
        return <Dashboard user={user} />;
      case "inbody":
        return <InBodySetup user={user} onComplete={() => {}} />;
      case "diet":
        return <DietTracker user={user} />;
      case "workout":
        return <WorkoutPlanner user={user} />;
      case "ai":
        return <AITrainer user={user} />;
      case "profile":
        return <Profile user={user} onLogout={onLogout} />;
      default:
        return <Dashboard user={user} />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      {renderScreen()}
      <BottomNavigation 
        currentScreen={currentScreen}
        onScreenChange={setCurrentScreen}
      />
    </div>
  );
}