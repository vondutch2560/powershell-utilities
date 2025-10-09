$OutputFile = "$env:USERPROFILE\Desktop\Hardware_Serial_Numbers.txt"

# 1. Khoi tao Noi dung file va Ghi thong tin co ban
Add-Content -Path $OutputFile -Value "--- THONG TIN SERIAL NUMBER HE THONG PC ---"
Add-Content -Path $OutputFile -Value "Ngay trich xuat: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $OutputFile -Value "-------------------------------------------"
Add-Content -Path $OutputFile -Value ""

# 2. Lay Serial Number cua He thong (BIOS)
$BIOS_SN = Get-CimInstance -ClassName Win32_Bios | Select-Object -ExpandProperty SerialNumber
Add-Content -Path $OutputFile -Value "System/BIOS Serial Number: $BIOS_SN"

# 3. Lay Serial Number cua Mainboard (Baseboard)
$MB_SN = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -ExpandProperty SerialNumber
Add-Content -Path $OutputFile -Value "Mainboard Serial Number: $MB_SN"

# 4. Lay Processor ID (thay vi CPU Serial Number)
$CPU_ID = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty ProcessorId
Add-Content -Path $OutputFile -Value "CPU Processor ID: $CPU_ID"

# 5. Lay Serial Number cua RAM (Memory)
Add-Content -Path $OutputFile -Value "`n--- RAM Serial Numbers (Moi chip) ---"
# Su dung Win32_PhysicalMedia de doc chip nho vat ly
$RAM_SNs = Get-CimInstance -ClassName Win32_PhysicalMedia | Where-Object {$_.MediaType -like "*Memory*"} | Select-Object Tag, SerialNumber, Manufacturer
foreach ($RAM in $RAM_SNs) {
    # Kiem tra cac gia tri Serial Number khong hop le
    if ($RAM.SerialNumber -and ($RAM.SerialNumber -ne "0") -and ($RAM.SerialNumber -ne "Default String")) {
        Add-Content -Path $OutputFile -Value "  - Khe cam: $($RAM.Tag) | Serial: $($RAM.SerialNumber)"
    } else {
        Add-Content -Path $OutputFile -Value "  - Khe cam: $($RAM.Tag) | Serial: KHONG CO/LOI DOC"
    }
}

# 6. Lay Serial Number cua O cung (Drives)
Add-Content -Path $OutputFile -Value "`n--- DRIVE Serial Numbers (SSD/HDD) ---"
$Drive_SNs = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, InterfaceType, SerialNumber
foreach ($Drive in $Drive_SNs) {
    Add-Content -Path $OutputFile -Value "  - Model: $($Drive.Model) | Loai: $($Drive.InterfaceType) | Serial: $($Drive.SerialNumber)"
}

# 7. Thong bao hoan tat
Write-Host "✅ Hoan tat! Du lieu da duoc luu vao $OutputFile" -ForegroundColor Green
