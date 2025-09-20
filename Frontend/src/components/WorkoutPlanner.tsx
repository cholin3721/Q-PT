import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { Calendar, Plus, Play, CheckCircle, X, Timer, Target } from "lucide-react";

interface WorkoutPlannerProps {
  user: any;
}

export function WorkoutPlanner({ user }: WorkoutPlannerProps) {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [activeWorkout, setActiveWorkout] = useState<any>(null);

  // Mock workout plan for today
  const todaysPlan = {
    id: 1,
    name: "Upper Body Strength",
    status: "active",
    totalSets: 12,
    completedSets: 4,
    exercises: [
      {
        id: 1,
        name: "Bench Press",
        sets: [
          { id: 1, targetWeight: 60, targetReps: 10, actualWeight: 60, actualReps: 10, status: "completed" },
          { id: 2, targetWeight: 60, targetReps: 10, actualWeight: 60, actualReps: 8, status: "completed" },
          { id: 3, targetWeight: 65, targetReps: 8, actualWeight: null, actualReps: null, status: "pending" }
        ]
      },
      {
        id: 2,
        name: "Incline Dumbbell Press",
        sets: [
          { id: 4, targetWeight: 25, targetReps: 12, actualWeight: 25, actualReps: 12, status: "completed" },
          { id: 5, targetWeight: 25, targetReps: 12, actualWeight: 25, actualReps: 10, status: "completed" },
          { id: 6, targetWeight: 25, targetReps: 12, actualWeight: null, actualReps: null, status: "pending" }
        ]
      },
      {
        id: 3,
        name: "Pull-ups",
        sets: [
          { id: 7, targetWeight: 0, targetReps: 8, actualWeight: null, actualReps: null, status: "pending" },
          { id: 8, targetWeight: 0, targetReps: 8, actualWeight: null, actualReps: null, status: "pending" },
          { id: 9, targetWeight: 0, targetReps: 8, actualWeight: null, actualReps: null, status: "pending" }
        ]
      },
      {
        id: 4,
        name: "Seated Row",
        sets: [
          { id: 10, targetWeight: 50, targetReps: 12, actualWeight: null, actualReps: null, status: "pending" },
          { id: 11, targetWeight: 50, targetReps: 12, actualWeight: null, actualReps: null, status: "pending" },
          { id: 12, targetWeight: 50, targetReps: 12, actualWeight: null, actualReps: null, status: "pending" }
        ]
      }
    ]
  };

  // Mock routine templates
  const routineTemplates = [
    { id: 1, name: "Upper Body", exercises: 4, sets: 12 },
    { id: 2, name: "Lower Body", exercises: 5, sets: 15 },
    { id: 3, name: "Full Body", exercises: 6, sets: 18 },
    { id: 4, name: "Cardio + Core", exercises: 3, sets: 8 }
  ];

  const handleStartWorkout = () => {
    setActiveWorkout(todaysPlan);
  };

  const handleCompleteSet = (setId: number, actualWeight: number, actualReps: number) => {
    // In real app, this would update the set status
    console.log(`Set ${setId} completed: ${actualWeight}kg x ${actualReps} reps`);
  };

  const handleSkipSet = (setId: number) => {
    console.log(`Set ${setId} skipped`);
  };

  const progressPercentage = (todaysPlan.completedSets / todaysPlan.totalSets) * 100;

  return (
    <div className="p-4 space-y-6">
      {/* Header */}
      <div className="pt-4">
        <h1 className="text-2xl text-gray-900">Workout Planner</h1>
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

      {/* Today's Workout Overview */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-start">
            <div>
              <CardTitle>{todaysPlan.name}</CardTitle>
              <p className="text-sm text-gray-500 mt-1">
                {todaysPlan.completedSets} / {todaysPlan.totalSets} sets completed
              </p>
            </div>
            <Badge variant={todaysPlan.status === "active" ? "default" : "secondary"}>
              {todaysPlan.status}
            </Badge>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <Progress value={progressPercentage} className="h-2" />
          
          {!activeWorkout ? (
            <div className="space-y-2">
              <Button onClick={handleStartWorkout} className="w-full">
                <Play className="w-4 h-4 mr-2" />
                Start Workout
              </Button>
              <div className="grid grid-cols-2 gap-2">
                <Button variant="outline" size="sm">
                  <Target className="w-4 h-4 mr-2" />
                  Edit Plan
                </Button>
                <Button variant="outline" size="sm">
                  <Timer className="w-4 h-4 mr-2" />
                  Set Timer
                </Button>
              </div>
            </div>
          ) : (
            <div className="bg-green-50 p-3 rounded-lg">
              <p className="text-sm text-green-700">✅ Workout in progress! Track your sets below.</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Exercise List / Active Workout */}
      {activeWorkout ? (
        <div className="space-y-4">
          <h2 className="text-lg text-gray-900">Current Workout</h2>
          
          {activeWorkout.exercises.map((exercise: any) => (
            <Card key={exercise.id}>
              <CardHeader>
                <CardTitle className="text-base">{exercise.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {exercise.sets.map((set: any, index: number) => (
                    <div key={set.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-3">
                        <span className="text-sm w-8">#{index + 1}</span>
                        <div className="text-sm">
                          <div>Target: {set.targetWeight}kg × {set.targetReps} reps</div>
                          {set.status === "completed" && (
                            <div className="text-green-600">
                              Actual: {set.actualWeight}kg × {set.actualReps} reps
                            </div>
                          )}
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        {set.status === "completed" ? (
                          <CheckCircle className="w-5 h-5 text-green-600" />
                        ) : (
                          <>
                            <Button 
                              size="sm" 
                              onClick={() => handleCompleteSet(set.id, set.targetWeight, set.targetReps)}
                            >
                              ✓
                            </Button>
                            <Button 
                              size="sm" 
                              variant="outline"
                              onClick={() => handleSkipSet(set.id)}
                            >
                              <X className="w-3 h-3" />
                            </Button>
                          </>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
          
          <Button 
            className="w-full" 
            onClick={() => setActiveWorkout(null)}
          >
            Finish Workout
          </Button>
        </div>
      ) : (
        /* Routine Templates */
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-lg text-gray-900">Quick Start Routines</h2>
            <Button size="sm" variant="outline">
              <Plus className="w-4 h-4 mr-2" />
              Create
            </Button>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            {routineTemplates.map((routine) => (
              <Card key={routine.id} className="p-4 cursor-pointer hover:bg-gray-50">
                <div className="text-center space-y-2">
                  <h3 className="text-sm">{routine.name}</h3>
                  <p className="text-xs text-gray-500">
                    {routine.exercises} exercises • {routine.sets} sets
                  </p>
                  <Button size="sm" variant="outline" className="w-full">
                    Load Routine
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Exercise Library */}
      <Card>
        <CardHeader>
          <CardTitle>Exercise Library</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-2">
            {[
              "Bench Press", "Squat", "Deadlift", "Pull-up",
              "Shoulder Press", "Row", "Dip", "Plank"
            ].map((exercise) => (
              <Button 
                key={exercise}
                variant="outline" 
                size="sm"
                className="justify-start"
              >
                {exercise}
              </Button>
            ))}
          </div>
          <Button variant="link" className="w-full mt-2 text-sm">
            View All Exercises →
          </Button>
        </CardContent>
      </Card>

      {/* Weekly Progress */}
      <Card>
        <CardHeader>
          <CardTitle>This Week's Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm">Workouts Completed</span>
              <span className="text-sm">4 / 5</span>
            </div>
            <Progress value={80} className="h-2" />
            
            <div className="grid grid-cols-3 gap-4 text-center pt-2">
              <div>
                <p className="text-lg text-blue-600">12</p>
                <p className="text-xs text-gray-500">Total Hours</p>
              </div>
              <div>
                <p className="text-lg text-green-600">156</p>
                <p className="text-xs text-gray-500">Sets Completed</p>
              </div>
              <div>
                <p className="text-lg text-orange-600">2.1k</p>
                <p className="text-xs text-gray-500">Calories Burned</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}