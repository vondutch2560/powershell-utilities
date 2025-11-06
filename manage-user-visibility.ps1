function Manage-LoginUserVisibility {
    
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }

    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    $ExcludedUsers = @("Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount", "HomeGroupUser$", "defaultuser0", "guest")
    $CurrentUser = $env:USERNAME
    $HiddenUsers = Get-Item -Path $RegPath | Select-Object -ExpandProperty Property
    $Users = Get-LocalUser | 
                Where-Object {$_.Name -notin $ExcludedUsers -and 
                              $_.Name -ne $CurrentUser -and
                              $_.Enabled -eq $true} | 
                Select-Object -ExpandProperty Name

    if (-not $Users) {
        Write-Warning "No other local user accounts found available for management."
        Write-Host "NOTE: The current user ('$CurrentUser') is automatically excluded." -ForegroundColor DarkYellow
        return
    }

    # 2. Build Selection Menu
    Write-Host "`n-- Local User Account List--`n" -ForegroundColor Cyan
    Write-Host "[VISIBLE] $CurrentUser (current user)" -ForegroundColor DarkGray

    for ($i = 0; $i -lt $Users.Count; $i++) {
        $UserName = $Users[$i]

        # Check current visibility status by checking the Registry
        $IsHidden = $hiddenUsers -contains $UserName

        # Display menu item
        if ($IsHidden) {
            Write-Host "[HIDDEN] " -ForegroundColor Red -NoNewline
        } else {
            Write-Host "[VISIBLE] " -ForegroundColor Green -NoNewline
        }
        Write-Host "$($i + 1). $UserName "
    }
    
    Write-Host
    Write-Host "-------------------------------"
    Write-Host "0. Exit" -ForegroundColor DarkGray

    # 3. Request User Selection
    Write-Host
    $Selection = Read-Host "Enter the number of the account you want to manage (1-$($Users.Count)) or 0 to exit"
    
    if ($Selection -eq "0") {
        Write-Host "Exiting script."
        return
    }
    
    # Validate selection
    if ($Selection -notmatch "^\d+$" -or $Selection -lt 1 -or $Selection -gt $Users.Count) {
        Write-Warning "Invalid selection."
        return
    }

    $SelectedUser = $Users[$Selection - 1]
    
    # 4. Request Action (Hide/Show)
    Write-Host "`nWhat would you like to do with the account '$SelectedUser'?" -ForegroundColor Cyan
    Write-Host "1. Hide $SelectedUser login screen (Create DWORD = 0)" -ForegroundColor Yellow
    Write-Host "2. Show $SelectedUser login screen (Delete DWORD)" -ForegroundColor Yellow
    $Action = Read-Host "Enter choice (1 or 2)"
    
    # 5. Execute Action
    try {        
        switch ($Action) {
            "1" { # Hide (Create DWORD = 0)
                New-ItemProperty -Path $RegPath -Name $SelectedUser -Value 0 -PropertyType DWord -Force | Out-Null
                Write-Host "✅ Successfully HIDDEN '$SelectedUser'." -ForegroundColor Green
            }
            "2" { # Show (Delete DWORD)
                Remove-ItemProperty -Path $RegPath -Name $SelectedUser -Force
                Write-Host "✅ Successfully SHOWN '$SelectedUser' again." -ForegroundColor Green
            }
            default {
                Write-Warning "Invalid action choice. Operation cancelled."
            }
        }
    
        # General notification
        if ($Action -in @("1", "2")) {
            Write-Host "Please restart the computer for changes to take effect." -ForegroundColor Magenta
        }
        
    } catch {
        Write-Error "An error occurred during Registry operation: $($_.Exception.Message)"
    }
}



# Run the main function
Manage-LoginUserVisibility
