import { useState } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { ArrowLeft } from "lucide-react";

interface AuthScreenProps {
  onAuthSuccess: (user: any) => void;
}

export function AuthScreen({ onAuthSuccess }: AuthScreenProps) {
  const [nickname, setNickname] = useState("");
  const [isCheckingNickname, setIsCheckingNickname] = useState(false);
  const [isNicknameAvailable, setIsNicknameAvailable] = useState<boolean | null>(null);
  const [step, setStep] = useState<"login" | "nickname">("login");

  const handleSocialLogin = async (provider: "google" | "kakao") => {
    // Mock social login
    console.log(`Logging in with ${provider}`);
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Simulate new user needs nickname
    setStep("nickname");
  };

  const handleNicknameCheck = async () => {
    if (!nickname.trim()) return;
    
    setIsCheckingNickname(true);
    
    // Mock nickname check API
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Simulate availability check
    const available = !["admin", "test", "user"].includes(nickname.toLowerCase());
    setIsNicknameAvailable(available);
    setIsCheckingNickname(false);
  };

  const handleCompleteSetup = () => {
    if (!isNicknameAvailable) return;
    
    // Mock user data
    const userData = {
      id: 1,
      nickname,
      email: "user@example.com",
      provider: "google"
    };
    
    onAuthSuccess(userData);
  };

  if (step === "nickname") {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center p-4">
        <Card className="max-w-md w-full">
          <CardHeader>
            <div className="flex items-center space-x-2">
              <Button 
                variant="ghost" 
                size="icon"
                onClick={() => setStep("login")}
              >
                <ArrowLeft className="w-4 h-4" />
              </Button>
              <div>
                <CardTitle>Choose Your Nickname</CardTitle>
                <CardDescription>This will be your display name in Q-PT</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="nickname">Nickname</Label>
              <div className="flex space-x-2">
                <Input
                  id="nickname"
                  value={nickname}
                  onChange={(e) => {
                    setNickname(e.target.value);
                    setIsNicknameAvailable(null);
                  }}
                  placeholder="Enter your nickname"
                />
                <Button 
                  onClick={handleNicknameCheck}
                  disabled={!nickname.trim() || isCheckingNickname}
                  variant="outline"
                >
                  {isCheckingNickname ? "..." : "Check"}
                </Button>
              </div>
              {isNicknameAvailable === true && (
                <p className="text-sm text-green-600">✓ Nickname is available</p>
              )}
              {isNicknameAvailable === false && (
                <p className="text-sm text-red-600">✗ Nickname is already taken</p>
              )}
            </div>
            
            <Button 
              onClick={handleCompleteSetup}
              disabled={!isNicknameAvailable}
              className="w-full"
            >
              Complete Setup
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center p-4">
      <Card className="max-w-md w-full">
        <CardHeader className="text-center">
          <CardTitle>Welcome to Q-PT</CardTitle>
          <CardDescription>Sign in to start your fitness journey</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button 
            onClick={() => handleSocialLogin("google")}
            className="w-full bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
          >
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-red-500 rounded-sm flex items-center justify-center text-white text-xs">
                G
              </div>
              <span>Continue with Google</span>
            </div>
          </Button>
          
          <Button 
            onClick={() => handleSocialLogin("kakao")}
            className="w-full bg-yellow-400 text-gray-800 hover:bg-yellow-500"
          >
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-gray-800 rounded-sm flex items-center justify-center text-yellow-400 text-xs">
                K
              </div>
              <span>Continue with Kakao</span>
            </div>
          </Button>
          
          <div className="text-center">
            <p className="text-xs text-gray-500">
              By signing in, you agree to our Terms of Service and Privacy Policy
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}