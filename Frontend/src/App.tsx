import { useState } from "react";
import { WelcomeScreen } from "./components/WelcomeScreen";
import { AuthScreen } from "./components/AuthScreen";
import { MainApp } from "./components/MainApp";

type Screen = "welcome" | "auth" | "app";

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>("welcome");
  const [user, setUser] = useState<any>(null);

  const handleGetStarted = () => {
    setCurrentScreen("auth");
  };

  const handleAuthSuccess = (userData: any) => {
    setUser(userData);
    setCurrentScreen("app");
  };

  const handleLogout = () => {
    setUser(null);
    setCurrentScreen("welcome");
  };

  if (currentScreen === "welcome") {
    return <WelcomeScreen onGetStarted={handleGetStarted} />;
  }

  if (currentScreen === "auth") {
    return <AuthScreen onAuthSuccess={handleAuthSuccess} />;
  }

  return <MainApp user={user} onLogout={handleLogout} />;
}