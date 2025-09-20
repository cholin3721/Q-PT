import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Progress } from "./ui/progress";
import { Button } from "./ui/button";
import { Calendar, Target, TrendingUp, Activity, Utensils, Dumbbell, Brain } from "lucide-react";

interface DashboardProps {
  user: any;
}

export function Dashboard({ user }: DashboardProps) {
  const today = new Date();
  const dateString = today.toLocaleDateString('ko-KR', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric',
    weekday: 'long'
  });

  // Mock data for demonstration
  const todayStats = {
    calories: 1480,
    targetCalories: 2000,
    protein: 85,
    targetProtein: 120,
    workoutsCompleted: 1,
    workoutsPlanned: 2
  };

  const weeklyGoals = {
    weightGoal: 68.0,
    currentWeight: 70.5,
    muscleGoal: 33.0,
    currentMuscle: 32.1,
    fatGoal: 10.0,
    currentFat: 12.8
  };

  return (
    <div className="p-4 space-y-6">
      {/* Header */}
      <div className="pt-4">
        <h1 className="text-2xl text-gray-900">안녕하세요, {user.nickname}님!</h1>
        <p className="text-sm text-gray-600 flex items-center space-x-1">
          <Calendar className="w-4 h-4" />
          <span>{dateString}</span>
        </p>
      </div>

      {/* Today's Overview */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Activity className="w-5 h-5 text-blue-600" />
            <span>Today's Progress</span>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm">Calories</span>
              <span className="text-sm">{todayStats.calories} / {todayStats.targetCalories}</span>
            </div>
            <Progress 
              value={(todayStats.calories / todayStats.targetCalories) * 100} 
              className="h-2"
            />
          </div>
          
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm">Protein</span>
              <span className="text-sm">{todayStats.protein}g / {todayStats.targetProtein}g</span>
            </div>
            <Progress 
              value={(todayStats.protein / todayStats.targetProtein) * 100} 
              className="h-2"
            />
          </div>
          
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm">Workouts</span>
              <span className="text-sm">{todayStats.workoutsCompleted} / {todayStats.workoutsPlanned}</span>
            </div>
            <Progress 
              value={(todayStats.workoutsCompleted / todayStats.workoutsPlanned) * 100} 
              className="h-2"
            />
          </div>
        </CardContent>
      </Card>

      {/* Goals Progress */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Target className="w-5 h-5 text-green-600" />
            <span>Weekly Goals</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p className="text-2xl text-blue-600">{weeklyGoals.currentWeight}kg</p>
              <p className="text-xs text-gray-500">Weight</p>
              <p className="text-xs text-gray-400">Goal: {weeklyGoals.weightGoal}kg</p>
            </div>
            <div>
              <p className="text-2xl text-green-600">{weeklyGoals.currentMuscle}kg</p>
              <p className="text-xs text-gray-500">Muscle</p>
              <p className="text-xs text-gray-400">Goal: {weeklyGoals.muscleGoal}kg</p>
            </div>
            <div>
              <p className="text-2xl text-orange-600">{weeklyGoals.currentFat}kg</p>
              <p className="text-xs text-gray-500">Body Fat</p>
              <p className="text-xs text-gray-400">Goal: {weeklyGoals.fatGoal}kg</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-4">
        <Card className="p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
              <Utensils className="w-5 h-5 text-orange-600" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm">Log Meal</h3>
              <p className="text-xs text-gray-500">Track your nutrition</p>
            </div>
          </div>
        </Card>
        
        <Card className="p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <Dumbbell className="w-5 h-5 text-green-600" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm">Start Workout</h3>
              <p className="text-xs text-gray-500">Begin your routine</p>
            </div>
          </div>
        </Card>
      </div>

      {/* AI Recommendations */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Brain className="w-5 h-5 text-purple-600" />
            <span>AI Recommendations</span>
          </CardTitle>
          <CardDescription>
            Based on your recent progress
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="bg-blue-50 p-3 rounded-lg">
            <p className="text-sm">💪 Your protein intake is below target. Consider adding a protein shake after your evening workout.</p>
          </div>
          <div className="bg-green-50 p-3 rounded-lg">
            <p className="text-sm">🎯 Great job on consistency! You've worked out 5 days this week. Tomorrow is your planned rest day.</p>
          </div>
          <div className="bg-orange-50 p-3 rounded-lg">
            <p className="text-sm">📈 Your lower body strength has improved 15% since last month. Consider adding more weight to your squats.</p>
          </div>
          <Button variant="outline" className="w-full">
            Get Detailed AI Analysis
          </Button>
        </CardContent>
      </Card>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <TrendingUp className="w-5 h-5 text-indigo-600" />
            <span>Recent Activity</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            <div className="flex items-center justify-between py-2 border-b border-gray-100">
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                <span className="text-sm">Upper Body Workout</span>
              </div>
              <span className="text-xs text-gray-500">2 hours ago</span>
            </div>
            <div className="flex items-center justify-between py-2 border-b border-gray-100">
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-orange-500 rounded-full"></div>
                <span className="text-sm">Lunch: Grilled Chicken Salad</span>
              </div>
              <span className="text-xs text-gray-500">3 hours ago</span>
            </div>
            <div className="flex items-center justify-between py-2">
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span className="text-sm">Breakfast: Protein Smoothie</span>
              </div>
              <span className="text-xs text-gray-500">8 hours ago</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}