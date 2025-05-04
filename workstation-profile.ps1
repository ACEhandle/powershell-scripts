oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\clean-detailed.omp.json" | Invoke-Expression

function Upgrade {
    python "d:\quarry\code\projects\ACEhandle\powershell-workstation\upgrade_powershell.py"
}

function lls {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$InputArgs
    )
    if ($InputArgs -and ($InputArgs[0] -eq 'h' -or $InputArgs[0] -eq '-h' -or $InputArgs[0] -eq '--help')) {
        Write-Host "lls - List all files and folders (including hidden) in a table."
        Write-Host "Each row shows: Permissions, Type, Size (in MB), and Name."
        Write-Host "File and directory sizes are displayed in megabytes (MB), rounded to two decimals."
        Write-Host "Usage: lls [path]"
        Write-Host "       lls -h | --help | h   # Show this help message"
        return
    }
    $targetPath = if ($InputArgs -and $InputArgs[0] -notmatch '^-') { $InputArgs[0] } else { Get-Location }
    $items = Get-ChildItem -Force -LiteralPath $targetPath | ForEach-Object {
        $type = if ($_.PSIsContainer) {'Directory'} else {'File'}
        $size = if ($_.PSIsContainer) {
            $s = (Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -File -LiteralPath $_.FullName | Measure-Object -Property Length -Sum).Sum
            if ($null -eq $s) { $s = 0 }
            $s
        } else {
            $_.Length
        }
        $sizeMB = [math]::Round($size / 1MB, 2)
        [PSCustomObject]@{
            Permissions = $_.Mode
            Type        = $type
            SizeMB      = $sizeMB
            Name        = $_.Name
            IsDir       = $_.PSIsContainer
            IsSystem    = $_.Attributes -band [IO.FileAttributes]::System
            IsHidden    = $_.Attributes -band [IO.FileAttributes]::Hidden
        }
    }
    $fmt = "{0,-12} {1,-10} {2,12} {3}"
    Write-Host ($fmt -f "Permissions", "Type", "Size (MB)", "Name") -ForegroundColor Yellow
    foreach ($item in $items) {
        $row = $fmt -f $item.Permissions, $item.Type, $item.SizeMB, $item.Name
        if ($item.IsDir -and $item.IsSystem) {
            Write-Host $row -ForegroundColor DarkYellow
        } elseif ($item.IsDir -and $item.IsHidden) {
            Write-Host $row -ForegroundColor Gray
        } elseif ($item.IsDir) {
            Write-Host $row -ForegroundColor Cyan
        } elseif ($item.IsSystem) {
            Write-Host $row -ForegroundColor DarkYellow
        } elseif ($item.IsHidden) {
            Write-Host $row -ForegroundColor Gray
        } else {
            Write-Host $row -ForegroundColor White
        }
    }
}

function Add-Path {
    param (
        [string]$path,
        [switch]$System
    )
    if ($env:Path -split ";" | Where-Object {$_ -eq $path}) {
        Write-Host "The path '$path' is already in the Path variable."
        return
    }
    if ($System) {
        $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable('Path', $currentPath + ";" + $path, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Path '$path' added to system Path."
    }
    else {
        $currentUserPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
        [System.Environment]::SetEnvironmentVariable('Path', $currentUserPath + ";" + $path, [System.EnvironmentVariableTarget]::User)
        Write-Host "Path '$path' added to user Path."
    }
}

function Show-Path {
    $env:Path -split ";" | ForEach-Object { Write-Host $_ }
}

function Remove-Path {
    param (
        [string]$path,
        [switch]$System
    )
    if ($System) {
        $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
        $newPath = ($currentPath -split ";") | Where-Object { $_ -ne $path }
        [System.Environment]::SetEnvironmentVariable('Path', ($newPath -join ";"), [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Path '$path' removed from system Path."
    }
    else {
        $currentUserPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
        $newUserPath = ($currentUserPath -split ";") | Where-Object { $_ -ne $path }
        [System.Environment]::SetEnvironmentVariable('Path', ($newUserPath -join ";"), [System.EnvironmentVariableTarget]::User)
        Write-Host "Path '$path' removed from user Path."
    }
}