
param(
    [Parameter()]
    [string]$Protocol,

    [Parameter()]
    [int]$Port
)

function Get-NgrokUrlPort{
    try {
        $content = (Invoke-WebRequest http://127.0.0.1:4040/api/tunnels).Content | ConvertFrom-Json
        return ($content).tunnels
    }
    catch {
        return $false
    }
}

function Send-NgrokUrlPort{
    param(
    [Parameter()]
    [string]$Url
)
    $msgbody = [PSCustomObject]@{
        "@context"= "http://schema.org/extensions";
        "@type"= "MessageCard";
        "themeColor"= "0076D7";
        "summary"= "ngrok";
        "sections"= @(@{
            "activityTitle"= "![TestImage](https://47a92947.ngrok.io/Content/Images/default.png)ngrok port started...";
            "activitySubtitle"="$Url";
            "markdown"= $true
        })
        } | ConvertTo-Json
        
    Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $msgbody -Uri ""
}



while($true){
    $ngrokPort = Get-NgrokUrlPort
    if($ngrokPort -eq $false){
        Write-Host "Ngrok is disconnected... Restarting..."
        $ngrokProc = Get-Process ngrok -ErrorAction SilentlyContinue
        if($ngrokProc -eq $true){
            $ngrokProc.CloseMainWindow()
            Start-Sleep -Seconds 5

            if (!$ngrokProc.HasExited) {
                $ngrokProc | Stop-Process -Force
            }
            Write-Host "Starting ngrok..."
            Start-Process -FilePath ".\ngrok.exe" -ArgumentList $Protocol, $Port, "-region ap" -WindowStyle minimized
        }else{
            Write-Host "Starting ngrok..."
            Start-Process -FilePath ".\ngrok.exe" -ArgumentList $Protocol, $Port, "-region ap" -WindowStyle minimized
        }
    }
    
    if(!((Get-NgrokUrlPort).public_url -eq $ngrokPort.public_url)){
        Write-Host "ngrok port updated... Sending new port..."
        Start-Sleep -Seconds 5
        $ngrokPort = Get-NgrokUrlPort
        Send-NgrokUrlPort -Url $ngrokPort.public_url
    }
    Start-Sleep -Seconds 60
}
