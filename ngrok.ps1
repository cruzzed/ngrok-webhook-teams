
param(
    [Parameter()]
    [string]$Protocol,

    [Parameter()]
    [int]$Port
)

function Get-NgrokUrlPort{
    try {
        $content = (Invoke-WebRequest http://127.0.0.1:4040/api/tunnels).Content | ConvertFrom-Json
        Write-Host "$content.tunnels"
        Write-Host "not catched"
        return ($content).tunnels
    }
    catch {
        #Write-Host "$_"
        return $false
    }
}

function Send-NgrokUrlPort{
    param(
    [Parameter()]
    [string]$Url
)
    $msgbody = '{"type":"message",
   "attachments":[
      {
         "contentType":"application/vnd.microsoft.card.adaptive",
         "contentUrl":null,
         "content":{
            "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type":"AdaptiveCard",
            "version":"1.2",
            "body":[
               {
                "ngrok url" : $Port
               }
            ]
         }
      }
   ]
}'
    Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body '{"@context": "http://schema.org/extensions","@type": "MessageCard", "text": "$Url"}' -Uri "https://outlook.office.com/webhook/b5f3ab75-4050-4d4c-9642-8ea60bfb1fa1@0fed03a3-402d-4633-a8cd-8b308822253e/IncomingWebhook/c667c24a3e7848bfab73abda4a811efd/9f733cad-f2cd-4a31-a88c-18ec153a4484"
}



while($true){
    $ngrokPort = Get-NgrokUrlPort
    Write-Host "bruh"
    Write-Host "$ngrokPort"
    if($ngrokPort -eq $false){
        Write-Host "Ha"
        $ngrokProc = Get-Process ngrok -ErrorAction SilentlyContinue
        if($ngrokProc -eq $true){
            $ngrokProc.CloseMainWindow()
            Start-Sleep -Seconds 5

            if (!$ngrokProc.HasExited) {
                $ngrokProc | Stop-Process -Force
            }
            Write-Host "Hmah"
            Start-Process -FilePath ".\ngrok.exe" -ArgumentList $Protocol, $Port, "-region ap" -WindowStyle minimized
        }else{
            Write-Host "test"
            Start-Process -FilePath ".\ngrok.exe" -ArgumentList $Protocol, $Port, "-region ap" -WindowStyle minimized
        }
    }
    Write-Host (Get-NgrokUrlPort).public_url
    Write-Host $ngrokPort.public_url
    if(!((Get-NgrokUrlPort).public_url -eq $ngrokPort.public_url)){
        Write-Host "not same"
        Start-Sleep -Seconds 5
        $ngrokPort = Get-NgrokUrlPort
        Send-NgrokUrlPort -Url $ngrokPort.public_url
    }

    Write-Host "meh"
    Start-Sleep -Seconds 60
}
