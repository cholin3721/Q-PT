import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Brain, MessageCircle, TrendingUp, Target, Calendar, Sparkles } from "lucide-react";

interface AITrainerProps {
  user: any;
}

export function AITrainer({ user }: AITrainerProps) {
  const [isGeneratingFeedback, setIsGeneratingFeedback] = useState(false);
  const [selectedPeriod, setSelectedPeriod] = useState<"week" | "month">("week");

  // Mock AI feedback history
  const feedbackHistory = [
    {
      id: 1,
      type: "weekly",
      date: "2024-01-15",
      analysis: "Excellent progress this week! Your consistency with workouts has improved significantly.",
      recommendations: [
        "Increase protein intake by 15g daily to support muscle recovery",
        "Add 5kg to your bench press next week", 
        "Consider adding one cardio session for cardiovascular health"
      ],
      metrics: {
        workoutConsistency: 85,
        nutritionScore: 78,
        progressRate: 92
      }
    },
    {
      id: 2,
      type: "monthly",
      date: "2024-01-01",
      analysis: "Your December performance shows strong dedication. Body composition improvements are on track.",
      recommendations: [
        "Transition to intermediate workout routine",
        "Focus on compound movements for better efficiency",
        "Track sleep quality to optimize recovery"
      ],
      metrics: {
        workoutConsistency: 82,
        nutritionScore: 74,
        progressRate: 88
      }
    }
  ];

  // Mock current data summary
  const currentSummary = {
    weeklyWorkouts: 4,
    avgCalories: 1850,
    proteinIntake: 95,
    sleepHours: 7.2,
    weightChange: -0.8,
    strengthProgress: 12
  };

  const handleGenerateFeedback = async () => {
    setIsGeneratingFeedback(true);
    
    // Mock AI analysis
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // In real app, this would call the AI API and add new feedback
    console.log("Generated new AI feedback");
    setIsGeneratingFeedback(false);
  };

  const latestFeedback = feedbackHistory[0];

  return (
    <div className="p-4 space-y-6">
      {/* Header */}
      <div className="pt-4">
        <h1 className="text-2xl text-gray-900">AI Personal Trainer</h1>
        <p className="text-sm text-gray-600 mt-1">
          Your intelligent fitness companion analyzing your progress
        </p>
      </div>

      {/* Quick Stats Summary */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <TrendingUp className="w-5 h-5 text-blue-600" />
            <span>Current Performance</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <p className="text-2xl text-green-600">{currentSummary.weeklyWorkouts}</p>
              <p className="text-xs text-gray-500">Workouts This Week</p>
            </div>
            <div className="text-center">
              <p className="text-2xl text-blue-600">{currentSummary.avgCalories}</p>
              <p className="text-xs text-gray-500">Avg Daily Calories</p>
            </div>
            <div className="text-center">
              <p className="text-2xl text-orange-600">{currentSummary.proteinIntake}g</p>
              <p className="text-xs text-gray-500">Daily Protein</p>
            </div>
            <div className="text-center">
              <p className="text-2xl text-purple-600">{currentSummary.strengthProgress}%</p>
              <p className="text-xs text-gray-500">Strength Increase</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Generate New Analysis */}
      <Card>
        <CardContent className="p-6 text-center space-y-4">
          <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mx-auto">
            <Brain className="w-8 h-8 text-white" />
          </div>
          <div>
            <h3 className="text-lg mb-2">Get AI Analysis</h3>
            <p className="text-sm text-gray-600 mb-4">
              Analyze your recent {selectedPeriod}ly data for personalized insights and recommendations
            </p>
            
            <div className="flex justify-center space-x-2 mb-4">
              <Button
                size="sm"
                variant={selectedPeriod === "week" ? "default" : "outline"}
                onClick={() => setSelectedPeriod("week")}
              >
                Weekly
              </Button>
              <Button
                size="sm"
                variant={selectedPeriod === "month" ? "default" : "outline"}
                onClick={() => setSelectedPeriod("month")}
              >
                Monthly
              </Button>
            </div>
            
            <Button 
              onClick={handleGenerateFeedback}
              disabled={isGeneratingFeedback}
              className="w-full"
            >
              {isGeneratingFeedback ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                  <span>Analyzing Your Data...</span>
                </div>
              ) : (
                <div className="flex items-center space-x-2">
                  <Sparkles className="w-4 h-4" />
                  <span>Generate {selectedPeriod.charAt(0).toUpperCase() + selectedPeriod.slice(1)}ly Analysis</span>
                </div>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Latest Feedback */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-start">
            <CardTitle className="flex items-center space-x-2">
              <MessageCircle className="w-5 h-5 text-green-600" />
              <span>Latest Analysis</span>
            </CardTitle>
            <Badge variant="secondary">
              {new Date(latestFeedback.date).toLocaleDateString()}
            </Badge>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="bg-blue-50 p-4 rounded-lg">
            <p className="text-sm">{latestFeedback.analysis}</p>
          </div>
          
          <div>
            <h4 className="text-sm mb-2">AI Recommendations:</h4>
            <div className="space-y-2">
              {latestFeedback.recommendations.map((rec, index) => (
                <div key={index} className="flex items-start space-x-2 text-sm">
                  <Target className="w-4 h-4 text-green-600 mt-0.5 flex-shrink-0" />
                  <span>{rec}</span>
                </div>
              ))}
            </div>
          </div>
          
          <div className="grid grid-cols-3 gap-4 pt-2">
            <div className="text-center">
              <div className="text-lg text-blue-600">{latestFeedback.metrics.workoutConsistency}%</div>
              <div className="text-xs text-gray-500">Workout Consistency</div>
            </div>
            <div className="text-center">
              <div className="text-lg text-green-600">{latestFeedback.metrics.nutritionScore}%</div>
              <div className="text-xs text-gray-500">Nutrition Score</div>
            </div>
            <div className="text-center">
              <div className="text-lg text-purple-600">{latestFeedback.metrics.progressRate}%</div>
              <div className="text-xs text-gray-500">Progress Rate</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Feedback History */}
      <div className="space-y-4">
        <h2 className="text-lg text-gray-900">Analysis History</h2>
        
        {feedbackHistory.slice(1).map((feedback) => (
          <Card key={feedback.id}>
            <CardContent className="p-4">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <Badge variant="outline" className="mb-2">
                    {feedback.type}ly Report
                  </Badge>
                  <p className="text-sm text-gray-600">{feedback.analysis}</p>
                </div>
                <div className="flex items-center space-x-1 text-xs text-gray-500">
                  <Calendar className="w-3 h-3" />
                  <span>{new Date(feedback.date).toLocaleDateString()}</span>
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-2 text-center text-xs">
                <div>
                  <div className="text-blue-600">{feedback.metrics.workoutConsistency}%</div>
                  <div className="text-gray-500">Workouts</div>
                </div>
                <div>
                  <div className="text-green-600">{feedback.metrics.nutritionScore}%</div>
                  <div className="text-gray-500">Nutrition</div>
                </div>
                <div>
                  <div className="text-purple-600">{feedback.metrics.progressRate}%</div>
                  <div className="text-gray-500">Progress</div>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* AI Tips */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Sparkles className="w-5 h-5 text-yellow-600" />
            <span>Smart Tips</span>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="bg-yellow-50 p-3 rounded-lg">
            <p className="text-sm">💡 Your workout intensity has plateaued. Consider progressive overload by increasing weight by 2.5kg next week.</p>
          </div>
          <div className="bg-green-50 p-3 rounded-lg">
            <p className="text-sm">🎯 Your nutrition timing is improving. Eating protein within 30 minutes post-workout has increased by 60%.</p>
          </div>
          <div className="bg-blue-50 p-3 rounded-lg">
            <p className="text-sm">📈 Based on your progress pattern, you're on track to reach your strength goals 2 weeks earlier than planned!</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}