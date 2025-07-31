#Persistent
#KeyHistory, 0
#NoEnv
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
#InstallKeybdHook
#UseHook
#SingleInstance, Force
#Persistent ; (Interception hotkeys do not stop AHK from exiting, so use this)
#include Lib\AutoHotInterception.ahk
global AHI := new AutoHotInterception()
global lastX := 0
global lastY := 0
global rcs_Enabled := 1
global rcs_Strength_X := 2.5
global rcs_Strength_Y := 3.0

SetKeyDelay,-1, 8
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay,-1
SendMode, InputThenPlay
SetBatchLines,-1
ListLines, Off
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High   
        
     
AntiShakeX := (A_ScreenHeight // 160)
AntiShakeY := (A_ScreenHeight // 128)
ZeroX := (A_ScreenWidth // 2)
ZeroY := (A_ScreenHeight // 2)
     
if (FileExist("config.ini")) 
{
}
Else
{
    IniWrite, 38, config.ini, AIM, aimbot_ColVn
    IniWrite, 1, config.ini, AIM, aimbot_Enabled
    IniWrite, 75, config.ini, AIM, aimbot_CFovX
    IniWrite, 75, config.ini, AIM, aimbot_CFovY
    IniWrite, 0.8, config.ini, AIM, aimbot_Speed_X
    IniWrite, 0.8, config.ini, AIM, aimbot_Speed_Y
    IniWrite, 0.5, config.ini, AIM, aimbot_min_jitter
	IniWrite, 1.5, config.ini, AIM, aimbot_max_jitter
    IniWrite, 0, config.ini, AIM, aimbot_only_hs_mode
    IniWrite, 0, config.ini, TRIGGER, trigger_Enabled
    IniWrite, 0, config.ini, TRIGGER, trigger_Ana_Mode
    IniWrite, 44, config.ini, TRIGGER, trigger_ColVn
    IniWrite, 250, config.ini, TRIGGER, trigger_Delay
    	
    	
}
     
IniRead, aimbot_ColVn, config.ini, AIM, aimbot_ColVn
IniRead, aimbot_Enabled, config.ini, AIM, aimbot_Enabled
IniRead, aimbot_CFovX, config.ini, AIM, aimbot_CFovX
IniRead, aimbot_CFovY, config.ini, AIM, aimbot_CFovY
IniRead, aimbot_Speed_X, config.ini, AIM, aimbot_Speed_X
IniRead, aimbot_Speed_Y, config.ini, AIM, aimbot_Speed_Y
IniRead, aimbot_min_jitter, config.ini, AIM, aimbot_min_jitter
IniRead, aimbot_max_jitter, config.ini, AIM, aimbot_max_jitter
IniRead, aimbot_only_hs_mode, config.ini, AIM, aimbot_only_hs_mode
IniRead, trigger_Enabled, config.ini, TRIGGER, trigger_Enabled
IniRead, trigger_Ana_Mode, config.ini, TRIGGER, trigger_Ana_Mode
IniRead, trigger_ColVn, config.ini, TRIGGER, trigger_ColVn
IniRead, trigger_Delay, config.ini, TRIGGER, trigger_Delay
IniRead, rcs_Enabled, config.ini, RCS, rcs_Enabled, 1
IniRead, rcs_Strength_X, config.ini, RCS, rcs_Strength_X, 2.5
IniRead, rcs_Strength_Y, config.ini, RCS, rcs_Strength_Y, 3.0

UpdateAimSpeed(enemyX, enemyY)
{
    global lastX, lastY, aimbot_Speed_X, aimbot_Speed_Y

    ; Evitar problemas con la primera detección
    if (lastX = 0 && lastY = 0) {
        lastX := enemyX
        lastY := enemyY
        return
    }

    ; Calcular el desplazamiento del enemigo
    speedX := enemyX - lastX
    speedY := enemyY - lastY

    ; Calcular la distancia al enemigo
    distancia := Sqrt((speedX * speedX) + (speedY * speedY))

    ; Ajustar la velocidad del aimbot en función de la distancia
    if (distancia > 50)  ; Si el enemigo está lejos
    {
        incremento := distancia / 150  ; Ajuste dinámico (antes era /100, lo bajamos para más estabilidad)
        aimbot_Speed_X := 1.2 + incremento
        aimbot_Speed_Y := 1.0 + incremento
    }
    else
    {
        aimbot_Speed_X := 1.2
        aimbot_Speed_Y := 1.0
    }

    ; Limitar la velocidad dentro de un rango óptimo
    if (aimbot_Speed_X > 5.8) {
        aimbot_Speed_X := 5.8
    }
    if (aimbot_Speed_Y > 5.5) {
        aimbot_Speed_Y := 5.5
    }

    ; Guardar la última posición **sin modificarla con la predicción**
    lastX := enemyX
    lastY := enemyY
}

IF (aimbot_only_hs_mode == 1)
{
    EMCol := "0x6D1864, 0x87417B, 0x772F6B"
}
Else IF (aimbot_only_hs_mode == 0)
{
    EMCol := "0xa22b96, 0x9f2f8f, 0x7f4579, 0x914579"
}
     
ScanL := ZeroX - aimbot_CFovX
ScanR := ZeroX + aimbot_CFovX
ScanT := ZeroY - aimbot_CFovY
ScanB := ZeroY + aimbot_CFovY
     
ScanL2 := ZeroX - 3
ScanR2 := ZeroX + 3
ScanT2 := ZeroY - 3
ScanB2 := ZeroY + 3
     
NearAimScanL := ZeroX - AntiShakeX
NearAimScanR := ZeroX + AntiShakeX
NearAimScanT := ZeroY - AntiShakeY
NearAimScanB := ZeroY + AntiShakeY

RCS_Apply()
{
    global rcs_Enabled, rcs_Strength_X, rcs_Strength_Y
    static lastShotTime := 0

    if (rcs_Enabled = 1 && GetKeyState("LButton", "P"))
    {
        ; Calcular el tiempo entre disparos
        currentTime := A_TickCount
        timeSinceLastShot := currentTime - lastShotTime
        lastShotTime := currentTime

        ; Si el tiempo entre disparos es mayor a 80ms, reseteamos el recoil
        if (timeSinceLastShot > 30)
        {
            MoveX := 0
            MoveY := 0
        }
        else
        {
            MoveX := -rcs_Strength_X * 0.5  ; Reduce la corrección en X
            MoveY := rcs_Strength_Y * 0.7  ; Reduce en Y para no ser agresivo
        }

        AHI.SendMouseMove(11, MoveX, MoveY)
    }
}




Loop, 
{
	PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, aimbot_ColVn, Fast RGB
	if (!ErrorLevel) 
	{
		; Si es la primera vez, inicializar lastX y lastY
		if (lastX = 0 && lastY = 0) {
			lastX := AimPixelX
			lastY := AimPixelY
		}

		; Ajustar la velocidad del aimbot en función del movimiento del enemigo
		UpdateAimSpeed(AimPixelX, AimPixelY)
    	loop, 10 
    	{
    		IF (aimbot_Enabled == 1)
    		{
    			KeyWait, LButton, D
    			PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, aimbot_ColVn, Fast RGB
    			AimX := AimPixelX - ZeroX
    			AimY := AimPixelY - ZeroY 
    			If ( AimX > 0 ) 
    			{
    				DirX := 1
    			}
    			If ( AimX < 0 ) 
    			{
    				DirX := -1
    			}
    			If ( AimY > 0 ) 
    			{
    				DirY := 1
    			}
    			If ( AimY < 0 ) 
    			{
    				DirY := -1
    			}
    			
				randomJitter := Random, aimbot_min_jitter, aimbot_max_jitter
				jitter := Random, 0, randomJitter
    			AimX += jitter / 100
    			AimY += jitter / 100
    			AimOffsetX := AimX * DirX
    			AimOffsetY := AimY * DirY
    			
				IF (AimOffsetX != ZeroX)
				{
					MoveX = (AimOffsetX > ZeroX) ? -(ZeroX - AimOffsetX) : AimOffsetX - ZeroX;
					MoveX = (MoveX + ZeroX > ZeroX * 2 || MoveX + ZeroX < 0) ? 0 : MoveX;
				}
				IF (AimOffsetY != 0)
				{
					IF (AimOffsetY != ZeroY)
					{
						MoveY = (AimOffsetY > ZeroY) ? -(ZeroY - AimOffsetY) : AimOffsetY - ZeroY;
						MoveY = (MoveY + ZeroY > ZeroY * 2 || MoveY + ZeroY < 0) ? 0 : MoveY;
					}
				}
				
				MoveX := (AimOffsetX * DirX) * aimbot_Speed_X / 10
    			MoveY := (AimOffsetY * DirY) * aimbot_Speed_Y / 10
				AHI.SendMouseMove(11, MoveX , MoveY )

				; Aplicar RCS después del aimbot
				RCS_Apply()
    		}
    			
    		IF (trigger_Enabled == 1)
    		{
    			IF (GetKeyState("LAlt"))
    			{
    				PixelSearch, AimPixelX, AimPixelY, ScanL2, ScanT2, ScanR2, ScanB2, EMCol, trigger_ColVn, Fast RGB
    				Loop , 1
    				{
    					AHI.SendMouseButtonEvent(11, 1, 1)
    					sleep, 50
    					AHI.SendMouseButtonEvent(11, 0, 0)
    					sleep, trigger_Delay
    				}
    			}       
    		}
    			
    		IF (trigger_Ana_Mode == 1)
    		{
    			IF (GetKeyState("LAlt"))
    			{
    				AnaCol := "0xde20de"
    				PixelSearch, AimPixelX, AimPixelY, ScanL2, ScanT2, ScanR2, ScanB2, EMCol, AnaCol, Fast RGB
    				Loop , 1
    				{
    					AHI.SendMouseButtonEvent(11, 1, 1)
    					sleep, 50
    					AHI.SendMouseButtonEvent(11, 0, 0)
    					sleep, trigger_Delay
    				}
    			}       
    		}
    	}
    }
}
return