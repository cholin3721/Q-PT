import { Home, Target, Utensils, Dumbbell, Brain, User } from "lucide-react";

type Screen = "dashboard" | "inbody" | "diet" | "workout" | "ai" | "profile";

interface BottomNavigationProps {
  currentScreen: Screen;
  onScreenChange: (screen: Screen) => void;
}

export function BottomNavigation({ currentScreen, onScreenChange }: BottomNavigationProps) {
  const navItems = [
    { id: "dashboard" as Screen, icon: Home, label: "Home" },
    { id: "diet" as Screen, icon: Utensils, label: "Diet" },
    { id: "workout" as Screen, icon: Dumbbell, label: "Workout" },
    { id: "ai" as Screen, icon: Brain, label: "AI Trainer" },
    { id: "profile" as Screen, icon: User, label: "Profile" },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-4 py-2">
      <div className="flex justify-around items-center max-w-lg mx-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentScreen === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => onScreenChange(item.id)}
              className={`flex flex-col items-center space-y-1 p-2 rounded-lg transition-colors ${
                isActive 
                  ? "text-blue-600 bg-blue-50" 
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              <Icon className="w-5 h-5" />
              <span className="text-xs">{item.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}