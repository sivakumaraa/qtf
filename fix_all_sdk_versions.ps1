#!/usr/bin/env pwsh
# Fix Android SDK versions in all pub cache plugins

$pubCachePath = "C:\Users\sivak\AppData\Local\Pub\Cache\hosted\pub.dev"
$targetSdk = "36"

Get-ChildItem $pubCachePath -Directory | ForEach-Object {
    $pluginPath = $_.FullName
    $buildGradle = Join-Path $pluginPath "android\build.gradle"
    
    if (Test-Path $buildGradle) {
        Write-Host "Fixing: $($_.Name)"
        
        $content = Get-Content $buildGradle -Raw
        
        # Replace compileSdkVersion and compileSdk  
        $content = $content -replace 'compileSdkVersion\s+\d+', "compileSdkVersion $targetSdk"
        $content = $content -replace 'compileSdk\s+\d+', "compileSdk $targetSdk"
        
        # Replace targetSdkVersion and targetSdk
        $content = $content -replace 'targetSdkVersion\s+\d+', "targetSdkVersion $targetSdk"
        $content = $content -replace 'targetSdk\s+\d+', "targetSdk $targetSdk"
        
        Set-Content $buildGradle -Value $content
        Write-Host "  Updated"
    }
}

Write-Host "All plugins updated to use SDK $targetSdk"


