
$OutputFile = "$env:USERPROFILE\Desktop\Hardware_Serial_Numbers.txt"

# 1. Khoi tao Noi dung file va Ghi thong tin co ban
Add-Content -Path $OutputFile -Value "--- THONG TIN SERIAL NUMBER LINH KIEN ---`n"
Add-Content -Path $OutputFile -Value "Ngay trich xuat: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $OutputFile -Value "-------------------------------------------"
Add-Content -Path $OutputFile -Value ""

# 1. Lay Processor ID (thay vi CPU Serial Number)
$CPU_ID = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty ProcessorId
Add-Content -Path $OutputFile -Value "CPU Processor ID: $CPU_ID"

# 2. Lay Serial Number cua He thong (BIOS)
$BIOS_SN = Get-CimInstance -ClassName Win32_Bios | Select-Object -ExpandProperty SerialNumber
Add-Content -Path $OutputFile -Value "Serial Number Bios: $BIOS_SN"

# 3. Lay Serial Number cua Mainboard (Baseboard)
$MB_SN = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -ExpandProperty SerialNumber
Add-Content -Path $OutputFile -Value "Serial Number Mainboard: $MB_SN"

# 4. Lay Serial Number cua RAM (Memory) - Su dung Win32_PhysicalMemory
Add-Content -Path $OutputFile -Value "`n--- RAM Serial Numbers (Moi chip) ---"
# Su dung Win32_PhysicalMemory de lay thong tin chi tiet (Dung luong, Serial, Part Number)
$RAM_SNs_New = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object DeviceLocator, Manufacturer, SerialNumber, PartNumber, @{Name="CapacityGB";Expression={[math]::Round($_.Capacity/1GB, 0)}}

foreach ($RAM in $RAM_SNs_New) {
    # Kiem tra cac gia tri Serial Number khong hop le
    $Serial = $RAM.SerialNumber
    
    # Tao chuoi thong tin day du
    $RAM_Info = "  - Khe cam: $($RAM.DeviceLocator) | Dung luong: $($RAM.CapacityGB)GB | Part No: $($RAM.PartNumber)"
    
    # Them Serial Number (co kiem tra loi doc)
    if ($Serial -and ($Serial -ne "0") -and ($Serial -ne "Default String") -and ($Serial -ne "Not Specified")) {
        Add-Content -Path $OutputFile -Value "$RAM_Info | Serial: $Serial"
    } else {
        Add-Content -Path $OutputFile -Value "$RAM_Info | Serial: KHONG CO/LOI DOC"
    }
}

# 5. Lay Serial Number cua O cung (Drives)
Add-Content -Path $OutputFile -Value "`n--- DRIVE Serial Numbers (SSD/HDD) ---"
$Drive_SNs = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, InterfaceType, SerialNumber
foreach ($Drive in $Drive_SNs) {
    Add-Content -Path $OutputFile -Value "  - Model: $($Drive.Model) | Loai: $($Drive.InterfaceType) | Serial: $($Drive.SerialNumber)"
}

# 7. Thong bao hoan tat
Write-Host "✅ Hoan tat! Du lieu da duoc luu vao $OutputFile" -ForegroundColor Green
