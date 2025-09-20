import { Button } from "./ui/button";
import { Card } from "./ui/card";
import { Activity, Target, Brain, BarChart3 } from "lucide-react";

interface WelcomeScreenProps {
  onGetStarted: () => void;
}

export function WelcomeScreen({ onGetStarted }: WelcomeScreenProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-green-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full space-y-8">
        {/* Logo and Brand */}
        <div className="text-center space-y-4">
          <div className="relative">
            <div className="w-20 h-20 mx-auto bg-gradient-to-br from-blue-500 via-orange-400 to-green-500 rounded-2xl flex items-center justify-center transform rotate-12">
              <Activity className="w-10 h-10 text-white" />
            </div>
          </div>
          <h1 className="text-4xl text-gray-900">Q-PT</h1>
          <p className="text-gray-600">AI. DATA. PERFORMANCE.</p>
          <p className="text-sm text-gray-500 max-w-xs mx-auto">
            Your quiet personal trainer, always by your side
          </p>
        </div>

        {/* Features */}
        <div className="space-y-4">
          <Card className="p-4 bg-white/80 backdrop-blur-sm border-0 shadow-lg">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <Target className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <h3 className="text-sm">InBody Integration</h3>
                <p className="text-xs text-gray-500">OCR-powered body composition tracking</p>
              </div>
            </div>
          </Card>

          <Card className="p-4 bg-white/80 backdrop-blur-sm border-0 shadow-lg">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                <BarChart3 className="w-5 h-5 text-orange-600" />
              </div>
              <div>
                <h3 className="text-sm">Smart Diet Tracking</h3>
                <p className="text-xs text-gray-500">AI-powered food analysis from photos</p>
              </div>
            </div>
          </Card>

          <Card className="p-4 bg-white/80 backdrop-blur-sm border-0 shadow-lg">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Activity className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <h3 className="text-sm">Workout Planner</h3>
                <p className="text-xs text-gray-500">Personalized exercise routines</p>
              </div>
            </div>
          </Card>

          <Card className="p-4 bg-white/80 backdrop-blur-sm border-0 shadow-lg">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                <Brain className="w-5 h-5 text-purple-600" />
              </div>
              <div>
                <h3 className="text-sm">AI Personal Trainer</h3>
                <p className="text-xs text-gray-500">Intelligent feedback and recommendations</p>
              </div>
            </div>
          </Card>
        </div>

        {/* CTA */}
        <div className="space-y-4">
          <Button 
            onClick={onGetStarted}
            className="w-full bg-gradient-to-r from-blue-600 to-green-600 hover:from-blue-700 hover:to-green-700 text-white py-6 rounded-xl shadow-lg"
          >
            Get Started
          </Button>
          <p className="text-xs text-center text-gray-500">
            Perfect for fitness beginners seeking affordable guidance
          </p>
        </div>
      </div>
    </div>
  );
}