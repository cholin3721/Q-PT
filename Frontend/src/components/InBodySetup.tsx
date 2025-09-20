import { useState } from "react";
import { Button } from "./ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import { Upload, Camera, Edit3, Target, CheckCircle } from "lucide-react";

interface InBodySetupProps {
  user: any;
  onComplete: () => void;
}

export function InBodySetup({ user, onComplete }: InBodySetupProps) {
  const [step, setStep] = useState<"upload" | "review" | "goals">("upload");
  const [isUploading, setIsUploading] = useState(false);
  const [ocrData, setOcrData] = useState<any>(null);

  const handleImageUpload = async (file: File) => {
    setIsUploading(true);
    
    // Mock OCR processing
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Mock OCR result
    const mockOcrData = {
      testDate: "2024-01-15",
      height: 175.0,
      weight: 70.5,
      muscleMass: 32.1,
      fatMass: 12.8,
      bmi: 23.0,
      bodyFatPercentage: 18.2,
      basalMetabolicRate: 1580,
      segmentalAnalysis: {
        rightArm: "standard",
        leftArm: "standard", 
        trunk: "standard",
        rightLeg: "under",
        leftLeg: "under"
      }
    };
    
    setOcrData(mockOcrData);
    setIsUploading(false);
    setStep("review");
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleImageUpload(file);
    }
  };

  const handleDataUpdate = (field: string, value: any) => {
    setOcrData(prev => ({ ...prev, [field]: value }));
  };

  const handleProceedToGoals = () => {
    setStep("goals");
  };

  const handleComplete = () => {
    // Here would be API call to save InBody data and goals
    console.log("Saving InBody data:", ocrData);
    onComplete();
  };

  if (step === "upload") {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-md mx-auto pt-8">
          <Card>
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center space-x-2">
                <Target className="w-6 h-6 text-blue-600" />
                <span>InBody Setup</span>
              </CardTitle>
              <CardDescription>
                Upload your InBody result sheet to get started with personalized recommendations
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {isUploading ? (
                <div className="text-center py-8">
                  <div className="animate-spin w-8 h-8 border-2 border-blue-600 border-t-transparent rounded-full mx-auto mb-4"></div>
                  <p className="text-sm text-gray-600">Analyzing your InBody data...</p>
                </div>
              ) : (
                <>
                  <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                    <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-sm text-gray-600 mb-4">
                      Take a photo or upload your InBody result sheet
                    </p>
                    <div className="space-y-2">
                      <Button 
                        className="w-full"
                        onClick={() => document.getElementById('file-upload')?.click()}
                      >
                        <Camera className="w-4 h-4 mr-2" />
                        Upload Photo
                      </Button>
                      <input
                        id="file-upload"
                        type="file"
                        accept="image/*"
                        onChange={handleFileSelect}
                        className="hidden"
                      />
                    </div>
                  </div>
                  
                  <div className="text-center">
                    <Button 
                      variant="outline" 
                      onClick={() => {
                        // Mock manual entry
                        const mockData = {
                          testDate: new Date().toISOString().split('T')[0],
                          height: 170,
                          weight: 70,
                          muscleMass: 30,
                          fatMass: 15,
                          bmi: 24.2,
                          bodyFatPercentage: 21.4,
                          basalMetabolicRate: 1500,
                          segmentalAnalysis: {
                            rightArm: "standard",
                            leftArm: "standard",
                            trunk: "standard", 
                            rightLeg: "standard",
                            leftLeg: "standard"
                          }
                        };
                        setOcrData(mockData);
                        setStep("review");
                      }}
                    >
                      <Edit3 className="w-4 h-4 mr-2" />
                      Enter Manually
                    </Button>
                  </div>
                </>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  if (step === "review") {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-md mx-auto pt-8">
          <Card>
            <CardHeader>
              <CardTitle>Review Your Data</CardTitle>
              <CardDescription>
                Please verify the extracted information and make any necessary corrections
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="height">Height (cm)</Label>
                  <Input
                    id="height"
                    type="number"
                    value={ocrData?.height || ""}
                    onChange={(e) => handleDataUpdate("height", parseFloat(e.target.value))}
                  />
                </div>
                <div>
                  <Label htmlFor="weight">Weight (kg)</Label>
                  <Input
                    id="weight"
                    type="number"
                    step="0.1"
                    value={ocrData?.weight || ""}
                    onChange={(e) => handleDataUpdate("weight", parseFloat(e.target.value))}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="muscle">Muscle Mass (kg)</Label>
                  <Input
                    id="muscle"
                    type="number"
                    step="0.1"
                    value={ocrData?.muscleMass || ""}
                    onChange={(e) => handleDataUpdate("muscleMass", parseFloat(e.target.value))}
                  />
                </div>
                <div>
                  <Label htmlFor="fat">Fat Mass (kg)</Label>
                  <Input
                    id="fat"
                    type="number"
                    step="0.1"
                    value={ocrData?.fatMass || ""}
                    onChange={(e) => handleDataUpdate("fatMass", parseFloat(e.target.value))}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="bmi">BMI</Label>
                  <Input
                    id="bmi"
                    type="number"
                    step="0.1"
                    value={ocrData?.bmi || ""}
                    onChange={(e) => handleDataUpdate("bmi", parseFloat(e.target.value))}
                  />
                </div>
                <div>
                  <Label htmlFor="bodyFat">Body Fat %</Label>
                  <Input
                    id="bodyFat"
                    type="number"
                    step="0.1"
                    value={ocrData?.bodyFatPercentage || ""}
                    onChange={(e) => handleDataUpdate("bodyFatPercentage", parseFloat(e.target.value))}
                  />
                </div>
              </div>
              
              <Button onClick={handleProceedToGoals} className="w-full">
                Continue to Goals
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-md mx-auto pt-8">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Target className="w-6 h-6 text-green-600" />
              <span>Set Your Goals</span>
            </CardTitle>
            <CardDescription>
              Based on your InBody data, we've suggested some goals. Feel free to adjust them.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="targetWeight">Target Weight (kg)</Label>
              <Input
                id="targetWeight"
                type="number"
                step="0.1"
                defaultValue={ocrData?.weight - 2}
              />
            </div>
            
            <div>
              <Label htmlFor="targetMuscle">Target Muscle Mass (kg)</Label>
              <Input
                id="targetMuscle"
                type="number"
                step="0.1"
                defaultValue={ocrData?.muscleMass + 1}
              />
            </div>
            
            <div>
              <Label htmlFor="targetFat">Target Fat Mass (kg)</Label>
              <Input
                id="targetFat"
                type="number"
                step="0.1"
                defaultValue={ocrData?.fatMass - 3}
              />
            </div>
            
            <div>
              <Label htmlFor="goals">Additional Goals (Optional)</Label>
              <Textarea
                id="goals"
                placeholder="e.g., Build strength, improve endurance, lose weight for health..."
                rows={3}
              />
            </div>
            
            <Button onClick={handleComplete} className="w-full">
              <CheckCircle className="w-4 h-4 mr-2" />
              Complete Setup
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}