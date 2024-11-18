classdef MockBrick < handle
    methods
        function brick = Brick(varargin) 
             
        end
        
        function delete(brick)
            
        end
        
        
        function send(brick, cmd)
            
        end
       
        function rmsg = receive(brick)
            
        end
        
        function voltage = uiReadVbatt(brick)
            
        end
        
        function level = uiReadLbatt(brick)
            
        end
        
        function level = GetBattVoltage(brick)
        end
        
        function level = GetBattLevel(brick)
        end
        
        function playTone(brick, volume, frequency, duration)  
            
        end
                 
        function beep(brick,volume,duration)
            
        end
        
        function playThreeTones(brick)
               
        end
        
        function name = inputDeviceGetName(brick,no)
            
        end
        
        function name = inputDeviceSymbol(brick,no)
            
        end
        
        function inputDeviceClrAll(brick)
            
        end
        
        function SetMode(brick,no,mode)
           
        end
        
        function reading = inputReadSI(brick,no,mode)
            
        end
        
        function msg = inputReadRaw(brick,no,mode,response_size)
                      
            
        end
        
        function reading = TouchPressed(brick, SensorPort)
        end
        
        function reading = TouchBumps(brick, SensorPort)
        end
        
        function SetColorMode(brick, SensorPort, mode)
        end
        
        function reading = LightReflect(brick, SensorPort)
        end
        
        function reading = LightAmbient(brick, SensorPort)
        end
        
        function reading = ColorCode(brick, SensorPort)
        end
        
        function reading = ColorRGB(brick, SensorPort)
            
        end
        
        function reading = UltrasonicDist(brick, SensorPort)
        end
        
        function GyroCalibrate(brick, SensorPort)
        end
        
        function reading = GyroAngle(brick, SensorPort)
        end
        
        function reading = GyroRate(brick, SensorPort)
        end
        
        function PlotSensor(brick,no,mode)
        end
            
        function displayColor(brick,no)
        end
        
        function StopMotor(brick,nos,brake)
        end
        
        
        function StopAllMotors(brick, brake)
        end
        
        function motorPower(brick,nos,power)
        end
        
        function motorStart(brick,nos)
            
        end
        
        function MoveMotor(brick, nos, power)
           
        end
        
        function state = MotorBusy(brick,nos)
            
        end
        
        function motorStepSpeed(brick,nos,speed,step1,step2,step3,brake)
            
        end
        
        function MoveMotorAngleRel(brick, nos, speed, angle, brake)
            
        end
        
        function MoveMotorAngleAbs(brick, nos, speed, angle, brake)
            
        end
        
        function ResetMotorAngle(brick, nos)
        end
        
        function motorClrCount(brick,nos)
            
        end
        
        function angle = GetMotorAngle(brick, nos)
        end
        
        function tacho = motorGetCount(brick,nos)
           
        end
        
        function WaitForMotor(brick, nos)
            
        end
        
        function drawTest(brick)
            
        end
        
        function name = getBrickName(brick)
            
        end
        
        function setBrickName(brick,name)
            
        end
        
        function mailBoxWrite(brick,brickname,boxname,type,msg)
            
        end      

        function fileUpload(brick,filename,dest)
           
        end
        
        function fileDownload(brick,dest,filename,maxlength)
            
        end
        
        function listFiles(brick,pathname,maxlength)
            
        end    
        
        function createDir(brick,pathname)
            
        end
        
        function deleteFile(brick,pathname)
            
        end
        
        function writeMailBox(brick,title,type,msg)
            
        end
        
        function [title,msg] = readMailBox(brick,type)
            
        end
            
        function threeToneByteCode(brick,filename)
        end
    end
end


function out = makenos(input)
    
end
 
function out = makebrake(input)
    
end



