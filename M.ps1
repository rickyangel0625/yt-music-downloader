# main.ps1 - YouTube 音樂下載助手
$url = Read-Host "Please paste the YouTube URL"

# 檔案儲存路徑（桌面）
$desktop = [Environment]::GetFolderPath("Desktop")

# 使用 yt-dlp 下載最佳音質的音訊（可能是 .webm）
yt-dlp.exe $url `
    -f "bestaudio" `
    --no-playlist `
    --no-cache `
    -o "$desktop\%(title)s.%(ext)s"


# 等待下載完成，然後轉換為 mp3
# 尋找最新下載的 .webm 或 .m4a 檔案
# 使用 -Include 參數指定多個副檔名
$latestFile = Get-ChildItem $desktop | Where-Object {
    $_.Extension -in ".webm", ".m4a"
} | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestFile) {
    # 使用 ffmpeg 轉換為 mp3 格式
    $outputFile = "$desktop\$($latestFile.BaseName).mp3"
    # 這裡的 ffmpeg 命令對於 .m4a 和 .webm 轉換為 .mp3 都是適用的
    # ffmpeg -i $latestFile.FullName -vn -ar 44100 -ac 2 -b:a 128k $outputFile
    ffmpeg -i "`"$($latestFile.FullName)`"" -vn -ar 44100 -ac 2 -b:a 128k "`"$outputFile`""

    # 刪除原始的 .webm 或 .m4a 檔案（可選）
    # Remove-Item $latestFile.FullName
    Remove-Item -LiteralPath $latestFile.FullName
    Write-Host "Conversion complete: $outputFile"
}
else {
    Write-Host "No .webm or .m4a file found to convert."
}

# 問是否要剪輯音樂
$edit = Read-Host "Do you want to edit your music?(y/n)"
if ($edit -eq "y") {
    Start-Process "https://mp3cut.net/tw/"
}
