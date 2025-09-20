import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { User, Settings, Target, BarChart3, Calendar, LogOut, Camera, Edit } from "lucide-react";

interface ProfileProps {
  user: any;
  onLogout: () => void;
}

export function Profile({ user, onLogout }: ProfileProps) {
  // Mock user data
  const userProfile = {
    nickname: user.nickname,
    email: user.email,
    joinDate: "2024-01-01",
    streak: 12,
    totalWorkouts: 45,
    totalMeals: 156
  };

  // Mock InBody history
  const inbodyHistory = [
    {
      date: "2024-01-15",
      weight: 70.5,
      muscleMass: 32.1,
      fatMass: 12.8,
      bodyFatPercentage: 18.2
    },
    {
      date: "2024-01-01", 
      weight: 72.0,
      muscleMass: 31.8,
      fatMass: 14.5,
      bodyFatPercentage: 20.1
    }
  ];

  // Mock current goals
  const currentGoals = {
    targetWeight: 68.0,
    targetMuscleMass: 33.0,
    targetFatMass: 10.0,
    deadline: "2024-03-01"
  };

  const handleInBodyUpdate = () => {
    console.log("Navigate to InBody update");
  };

  const handleGoalsUpdate = () => {
    console.log("Navigate to goals update");
  };

  const handleSettings = () => {
    console.log("Navigate to settings");
  };

  return (
    <div className="p-4 space-y-6">
      {/* Header */}
      <div className="pt-4">
        <h1 className="text-2xl text-gray-900">Profile</h1>
        <p className="text-sm text-gray-600 mt-1">
          Manage your account and track your journey
        </p>
      </div>

      {/* User Info */}
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-green-500 rounded-full flex items-center justify-center">
              <User className="w-8 h-8 text-white" />
            </div>
            <div className="flex-1">
              <h2 className="text-lg">{userProfile.nickname}</h2>
              <p className="text-sm text-gray-600">{userProfile.email}</p>
              <p className="text-xs text-gray-500 mt-1">
                Member since {new Date(userProfile.joinDate).toLocaleDateString()}
              </p>
            </div>
            <Button size="sm" variant="outline">
              <Edit className="w-4 h-4" />
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Stats Overview */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <BarChart3 className="w-5 h-5 text-blue-600" />
            <span>Your Journey</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p className="text-2xl text-blue-600">{userProfile.streak}</p>
              <p className="text-xs text-gray-500">Day Streak</p>
            </div>
            <div>
              <p className="text-2xl text-green-600">{userProfile.totalWorkouts}</p>
              <p className="text-xs text-gray-500">Workouts</p>
            </div>
            <div>
              <p className="text-2xl text-orange-600">{userProfile.totalMeals}</p>
              <p className="text-xs text-gray-500">Meals Logged</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Current Goals */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <CardTitle className="flex items-center space-x-2">
              <Target className="w-5 h-5 text-green-600" />
              <span>Current Goals</span>
            </CardTitle>
            <Button size="sm" variant="outline" onClick={handleGoalsUpdate}>
              <Edit className="w-4 h-4" />
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm">Target Weight</span>
            <span className="text-sm">{currentGoals.targetWeight}kg</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-sm">Target Muscle Mass</span>
            <span className="text-sm">{currentGoals.targetMuscleMass}kg</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-sm">Target Fat Mass</span>
            <span className="text-sm">{currentGoals.targetFatMass}kg</span>
          </div>
          <div className="pt-2 border-t">
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Target Date</span>
              <Badge variant="secondary">
                {new Date(currentGoals.deadline).toLocaleDateString()}
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* InBody History */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <CardTitle className="flex items-center space-x-2">
              <Calendar className="w-5 h-5 text-purple-600" />
              <span>InBody History</span>
            </CardTitle>
            <Button size="sm" variant="outline" onClick={handleInBodyUpdate}>
              <Camera className="w-4 h-4 mr-2" />
              Add New
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {inbodyHistory.map((record, index) => (
              <div key={index} className="border-l-2 border-blue-200 pl-4 pb-4">
                <div className="flex justify-between items-start mb-2">
                  <Badge variant="outline">
                    {new Date(record.date).toLocaleDateString()}
                  </Badge>
                  {index === 0 && <Badge variant="default">Latest</Badge>}
                </div>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-gray-600">Weight: </span>
                    <span>{record.weight}kg</span>
                  </div>
                  <div>
                    <span className="text-gray-600">Muscle: </span>
                    <span>{record.muscleMass}kg</span>
                  </div>
                  <div>
                    <span className="text-gray-600">Fat: </span>
                    <span>{record.fatMass}kg</span>
                  </div>
                  <div>
                    <span className="text-gray-600">Body Fat: </span>
                    <span>{record.bodyFatPercentage}%</span>
                  </div>
                </div>
                {index === 0 && inbodyHistory.length > 1 && (
                  <div className="mt-2 pt-2 border-t border-gray-100">
                    <div className="grid grid-cols-3 gap-2 text-xs">
                      <div className="text-center">
                        <span className={`${record.weight < inbodyHistory[1].weight ? 'text-green-600' : 'text-red-600'}`}>
                          {record.weight > inbodyHistory[1].weight ? '+' : ''}{(record.weight - inbodyHistory[1].weight).toFixed(1)}kg
                        </span>
                        <div className="text-gray-500">Weight</div>
                      </div>
                      <div className="text-center">
                        <span className={`${record.muscleMass > inbodyHistory[1].muscleMass ? 'text-green-600' : 'text-red-600'}`}>
                          {record.muscleMass > inbodyHistory[1].muscleMass ? '+' : ''}{(record.muscleMass - inbodyHistory[1].muscleMass).toFixed(1)}kg
                        </span>
                        <div className="text-gray-500">Muscle</div>
                      </div>
                      <div className="text-center">
                        <span className={`${record.fatMass < inbodyHistory[1].fatMass ? 'text-green-600' : 'text-red-600'}`}>
                          {record.fatMass > inbodyHistory[1].fatMass ? '+' : ''}{(record.fatMass - inbodyHistory[1].fatMass).toFixed(1)}kg
                        </span>
                        <div className="text-gray-500">Fat</div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Settings & Actions */}
      <Card>
        <CardContent className="p-4 space-y-3">
          <Button 
            variant="outline" 
            className="w-full justify-start"
            onClick={handleSettings}
          >
            <Settings className="w-4 h-4 mr-3" />
            Settings & Preferences
          </Button>
          
          <Button 
            variant="outline" 
            className="w-full justify-start text-red-600 hover:text-red-700 hover:bg-red-50"
            onClick={onLogout}
          >
            <LogOut className="w-4 h-4 mr-3" />
            Sign Out
          </Button>
        </CardContent>
      </Card>

      {/* App Info */}
      <Card>
        <CardContent className="p-4 text-center">
          <div className="w-12 h-12 bg-gradient-to-br from-blue-500 via-orange-400 to-green-500 rounded-lg flex items-center justify-center mx-auto mb-3">
            <User className="w-6 h-6 text-white" />
          </div>
          <h3 className="text-lg text-gray-900 mb-1">Q-PT</h3>
          <p className="text-sm text-gray-600 mb-2">AI. DATA. PERFORMANCE.</p>
          <p className="text-xs text-gray-500">Version 1.0.0</p>
        </CardContent>
      </Card>
    </div>
  );
}