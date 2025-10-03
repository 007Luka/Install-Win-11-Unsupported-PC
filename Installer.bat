@echo off
rem ===============================================
rem   Greek Nea Windows 11 25H2 Installer
rem ===============================================
echo.

setlocal EnableExtensions EnableDelayedExpansion
set "SCRIPT=Install_Win11_unsupported.ps1"
set "FULLPATH=%~dp0%SCRIPT%"
set "RAW_URL=https://raw.githubusercontent.com/007Luka/Install-Win-11-Unsupported-PC/main/Install_Win11_unsupported.ps1"

:: Βρίσκουμε τη γλώσσα του συστήματος (EL = Greek, αλλιώς Αγγλικά)
for /f "delims=" %%L in ('powershell -NoProfile -Command "(Get-Culture).TwoLetterISOLanguageName"') do set "LANG=%%L"

:: Συνάρτηση για χρωματιστά μηνύματα
:PrintMsg
rem %1 = τύπος: INFO, WARNING, ERROR
rem %2 = Greek μήνυμα
rem %3 = English μήνυμα
if "%~1"=="INFO" color 0A
if "%~1"=="WARNING" color 0E
if "%~1"=="ERROR" color 0C
if /i "%LANG%"=="el" (
    echo %~2
) else (
    echo %~3
)
color 07
exit /b

rem 1) Έλεγχος αν υπάρχει το PS1 (προσφέρεται αυτόματο κατέβασμα)
if exist "%FULLPATH%" (
    call :PrintMsg INFO "Βρέθηκε το %SCRIPT% σε αυτόν τον φάκελο." "%SCRIPT% found in this folder."
) else (
    call :PrintMsg WARNING "ΠΡΟΕΙΔΟΠΟΙΗΣΗ: Το %SCRIPT% δεν βρέθηκε εδώ." "WARNING: %SCRIPT% not found here."
    choice /M "Θέλετε να το κατεβάσετε τώρα από το επίσημο αποθετήριο GitHub; / Download it now from the official GitHub repo?"
    if errorlevel 2 (
        call :PrintMsg ERROR "Τοποθετήστε το %SCRIPT% σε αυτόν τον φάκελο και τρέξτε ξανά." "Please place %SCRIPT% in this folder and run again."
        pause
        exit /b 1
    ) else (
        call :PrintMsg INFO "Κατεβάζω το %SCRIPT% με progress bar..." "Downloading %SCRIPT% with progress bar..."
        powershell -NoProfile -Command ^
        "try { 
            $url='%RAW_URL%'; 
            $dest='%FULLPATH%'; 
            $wc = New-Object System.Net.WebClient; 
            $wc.DownloadProgressChanged += { Write-Progress -Activity 'Κατέβασμα αρχείου / Downloading file' -Status $('%SCRIPT%') -PercentComplete $_.ProgressPercentage }; 
            $wc.DownloadFileAsync($url, $dest); 
            while ($wc.IsBusy) { Start-Sleep -Milliseconds 100 } 
        } catch { Write-Host 'Το κατέβασμα απέτυχε / Download failed:' $_; exit 1 }"

        if not exist "%FULLPATH%" (
            call :PrintMsg ERROR "Το κατέβασμα απέτυχε. Κατεβάστε το χειροκίνητα από:" "Download failed. Manually download from:"
            echo %RAW_URL%
            pause
            exit /b 1
        )
        call :PrintMsg INFO "Κατέβηκε με επιτυχία!" "%SCRIPT% downloaded successfully!"
    )
)

rem 2) Ξεκλείδωμα του αρχείου
powershell -NoProfile -Command "try { Unblock-File -Path '%FULLPATH%' -ErrorAction SilentlyContinue } catch {}"

rem 3) Ρύθμιση πολιτικής εκτέλεσης
powershell -NoProfile -Command "try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction SilentlyContinue } catch {}"
powershell -NoProfile -Command "try { Set-ExecutionPolicy -Scope Process Bypass -Force -ErrorAction SilentlyContinue } catch {}"

rem 4) Εκκίνηση του PowerShell με αυξημένα προνόμια
call :PrintMsg INFO "Εκκίνηση του εγκαταστάτη (θα ζητηθούν δικαιώματα Διαχειριστή)..." "Launching installer (Administrator privileges will be requested)..."
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process -FilePath 'powershell' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%FULLPATH%\"' -Verb RunAs"

endlocal
exit /b
