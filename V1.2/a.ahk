#SingleInstance Force
Menu Tray, NoIcon
ColVn := 13
ColA := 0x221200
ScanL := 116 
ScanT := 25
ScanR := 125
ScanB := 135
SetKeyDelay, -1, 0
SetMouseDelay, -1
SetBatchLines, -1
SetWinDelay, -1
ListLines, Off
CoordMode, Pixel, Client , RGB
CoordMode, Mouse, Client 

; Kalman filter variables
KalmanX := 0
KalmanY := 0
KalmanP := 2
KalmanQ := 48.0  
KalmanR := 6.0  
KalmanVx := 0  
KalmanVy := 0  

global Sensitivity := 0.1

while(true) {
    	PixelSearch, X2, AimPixelY, ScanL, ScanB, ScanR, ScanT, ColA, ColVn, Fast RGB
        if (ErrorLevel) 
            continue

        AimX := (X2 - 121)
        MoveX := Round(AimX * (AimPixelY / 15.0))

        if (MoveX > 100 || MoveX < -100) ; جلوگیری از حرکت‌های غیرواقعی
            continue

        ; Kalman filter: Predict
        KalmanX := KalmanX + KalmanVx
        KalmanP := KalmanP + KalmanQ

        ; Kalman filter: Update
        K := KalmanP / (KalmanP + KalmanR)
        KalmanX := KalmanX + K * (MoveX - KalmanX)
        KalmanVx := K * (MoveX - KalmanX)
        KalmanP := (1 - K) * KalmanP

        ; Apply smoothing with EMA (Exponential Moving Average)
        Alpha := 4
        SmoothedX := (1 - Alpha) * KalmanX + Alpha * MoveX

        ; Move the mouse
        DllCall("mouse_event", uint, 1, int, SmoothedX * 1.5, int, 0, uint, 0, int, 1) 
}
