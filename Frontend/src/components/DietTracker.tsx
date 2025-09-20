import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Camera, Plus, Search, Calendar } from "lucide-react";
import { Progress } from "./ui/progress";

interface DietTrackerProps {
  user: any;
}

export function DietTracker({ user }: DietTrackerProps) {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);

  // Mock nutrition data for the day
  const dailyNutrition = {
    calories: { current: 1480, target: 2000 },
    protein: { current: 85, target: 120 },
    carbs: { current: 180, target: 250 },
    fat: { current: 45, target: 65 }
  };

  // Mock meal data
  const meals = [
    {
      id: 1,
      type: 1,
      time: "08:30",
      name: "Breakfast",
      foods: [
        { name: "Protein Smoothie", calories: 320, protein: 25 },
        { name: "Banana", calories: 105, protein: 1 }
      ],
      totalCalories: 425,
      image: null
    },
    {
      id: 2,
      type: 2,
      time: "13:15",
      name: "Lunch", 
      foods: [
        { name: "Grilled Chicken Breast", calories: 185, protein: 35 },
        { name: "Mixed Salad", calories: 45, protein: 3 },
        { name: "Brown Rice", calories: 220, protein: 5 }
      ],
      totalCalories: 450,
      image: "/api/placeholder/300/200"
    },
    {
      id: 3,
      type: 3,
      time: "19:45",
      name: "Dinner",
      foods: [
        { name: "Salmon Fillet", calories: 280, protein: 39 },
        { name: "Steamed Vegetables", calories: 80, protein: 4 },
        { name: "Sweet Potato", calories: 245, protein: 2 }
      ],
      totalCalories: 605,
      image: "/api/placeholder/300/200"
    }
  ];

  const handlePhotoAnalysis = async () => {
    setIsAnalyzing(true);
    
    // Mock AI analysis
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Mock result - in real app this would add a new meal
    console.log("AI analysis complete");
    setIsAnalyzing(false);
  };

  const handleAddMeal = () => {
    console.log("Manual meal entry");
  };

  return (
    <div className="p-4 space-y-6">
      {/* Header */}
      <div className="pt-4">
        <h1 className="text-2xl text-gray-900">Diet Tracker</h1>
        <div className="flex items-center space-x-2 mt-2">
          <Calendar className="w-4 h-4 text-gray-500" />
          <input
            type="date"
            value={selectedDate}
            onChange={(e) => setSelectedDate(e.target.value)}
            className="text-sm text-gray-600 bg-transparent border-none outline-none"
          />
        </div>
      </div>

      {/* Daily Nutrition Overview */}
      <Card>
        <CardHeader>
          <CardTitle>Daily Nutrition</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <div className="flex justify-between items-center mb-1">
              <span className="text-sm">Calories</span>
              <span className="text-sm">{dailyNutrition.calories.current} / {dailyNutrition.calories.target}</span>
            </div>
            <Progress 
              value={(dailyNutrition.calories.current / dailyNutrition.calories.target) * 100} 
              className="h-2"
            />
          </div>
          
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <div className="text-lg text-blue-600">{dailyNutrition.protein.current}g</div>
              <div className="text-xs text-gray-500">Protein</div>
              <div className="text-xs text-gray-400">Goal: {dailyNutrition.protein.target}g</div>
            </div>
            <div className="text-center">
              <div className="text-lg text-green-600">{dailyNutrition.carbs.current}g</div>
              <div className="text-xs text-gray-500">Carbs</div>
              <div className="text-xs text-gray-400">Goal: {dailyNutrition.carbs.target}g</div>
            </div>
            <div className="text-center">
              <div className="text-lg text-orange-600">{dailyNutrition.fat.current}g</div>
              <div className="text-xs text-gray-500">Fat</div>
              <div className="text-xs text-gray-400">Goal: {dailyNutrition.fat.target}g</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Add Meal Actions */}
      <div className="grid grid-cols-2 gap-4">
        <Button 
          onClick={handlePhotoAnalysis}
          disabled={isAnalyzing}
          className="h-20 flex-col space-y-2"
        >
          <Camera className="w-6 h-6" />
          <span className="text-sm">
            {isAnalyzing ? "Analyzing..." : "Photo Analysis"}
          </span>
        </Button>
        
        <Button 
          variant="outline"
          onClick={handleAddMeal}
          className="h-20 flex-col space-y-2"
        >
          <Plus className="w-6 h-6" />
          <span className="text-sm">Add Manually</span>
        </Button>
      </div>

      {/* Meal History */}
      <div className="space-y-4">
        <h2 className="text-lg text-gray-900">Today's Meals</h2>
        
        {meals.map((meal) => (
          <Card key={meal.id}>
            <CardContent className="p-4">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <h3 className="text-base">{meal.name}</h3>
                  <p className="text-sm text-gray-500">{meal.time}</p>
                </div>
                <Badge variant="secondary">{meal.totalCalories} kcal</Badge>
              </div>
              
              {meal.image && (
                <div className="mb-3">
                  <div className="w-full h-32 bg-gray-200 rounded-lg flex items-center justify-center">
                    <span className="text-gray-500 text-sm">Meal Photo</span>
                  </div>
                </div>
              )}
              
              <div className="space-y-1">
                {meal.foods.map((food, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span className="text-gray-700">{food.name}</span>
                    <span className="text-gray-500">{food.calories}kcal • {food.protein}g protein</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Quick Search */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Search className="w-5 h-5" />
            <span>Quick Add Food</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-2">
            {[
              "Apple", "Chicken Breast", "Brown Rice", "Egg",
              "Banana", "Salmon", "Oatmeal", "Greek Yogurt"
            ].map((food) => (
              <Button 
                key={food}
                variant="outline" 
                size="sm"
                className="justify-start"
              >
                {food}
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* AI Insights */}
      <Card>
        <CardHeader>
          <CardTitle>Nutrition Insights</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="bg-blue-50 p-3 rounded-lg">
            <p className="text-sm">📊 You're 35g short of your protein goal. Consider adding a protein shake or lean meat.</p>
          </div>
          <div className="bg-green-50 p-3 rounded-lg">
            <p className="text-sm">✅ Great job maintaining your calorie target! You're within 520 calories of your goal.</p>
          </div>
          <div className="bg-orange-50 p-3 rounded-lg">
            <p className="text-sm">🥗 Your vegetable intake is excellent today. Keep up the good work with micronutrients!</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}