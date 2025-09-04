@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 設定下載資料夾 (下載)
set "downloadFolder=%USERPROFILE%\Downloads"

:start
cls
echo 提示：在執行此程式前，請確保以下執行檔已下載並放置在此批次檔的相同資料夾內：
echo.
echo 1. yt-dlp.exe (用於下載 YouTube 影片音訊)
echo    下載連結: https://github.com/yt-dlp/yt-dlp/releases
echo    請下載 Assets 區塊下的 "yt-dlp.exe"
echo.
echo 2. FFmpeg 工具包 (包含 ffmpeg.exe 和 ffprobe.exe，用於音訊轉換)
echo    下載連結: https://www.ffmpeg.org/download.html
echo    點擊綠色 Windows 圖示，然後選擇其中一個下載連結 (例如 gyan.dev 或 BtbN)，
echo    下載解壓縮後，取得 bin 資料夾內的 "ffmpeg.exe" 和 "ffprobe.exe"。
echo.
pause

:loop
cls
echo ---------------------------------------------
echo YouTube 音樂下載助手 - MP3 (128 kbps)
echo ---------------------------------------------
set /p "url=請貼上 YouTube 網址 (或直接 Enter 結束): "

if "%url%"=="" exit /b

echo.
echo [1/2] 正在下載音訊...
yt-dlp.exe "%url%" ^
    -f "bestaudio" ^
    --no-playlist ^
    --no-cache ^
    --paths "%downloadFolder%" ^
    -o "%%(title)s.%%(ext)s"

if %errorlevel% neq 0 (
    echo 下載失敗，請檢查網址或網路。
    pause
    goto loop
)

echo.
echo [2/2] 正在轉換為 MP3 (128 kbps)...

set "latestFile="
for /f "delims=" %%i in ('dir /b /a-d /o-d "%downloadFolder%\*.webm" "%downloadFolder%\*.m4a" "%downloadFolder%\*.mp4" 2^>nul') do (
    if not defined latestFile set "latestFile=%%i"
)

if not defined latestFile (
    echo 錯誤：找不到下載檔案。
    pause
    goto loop
)

set "baseName=%latestFile%"
set "baseName=!baseName:.webm=!"
set "baseName=!baseName:.m4a=!"
set "baseName=!baseName:.mp4=!"
set "outputFile=%downloadFolder%\!baseName!.mp3"

ffmpeg -i "%downloadFolder%\!latestFile!" -vn -ar 44100 -ac 2 -b:a 128k "!outputFile!"

if %errorlevel% neq 0 (
    echo 轉換失敗！
    pause
    goto loop
)

del "%downloadFolder%\!latestFile!"
echo.
echo ✅ 完成：!outputFile!
echo ---------------------------------------------
echo.

goto loop
