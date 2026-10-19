<#
  registration-dates-tool.ps1 — فك وإعادة تشفير قاعدة تواريخ التسجيل (registration_dates.bin)
  الاستخدام:
      .\registration-dates-tool.ps1 decode -File "C:\work\unpack-apktool\assets\extera\registration_dates.bin"
      .\registration-dates-tool.ps1 encode -File "C:\work\registration_dates_decoded.json" -OutFile "new_registration_dates.bin"
  الخوارزمية: نفس InvisibleEncryptor المستخدمة في التطبيق (نظام base-11 بحروف غير مرئية).
#>
param(
    [Parameter(Mandatory=$true, Position=0)][ValidateSet('decode','encode')][string]$Mode,
    [Parameter(Mandatory=$true)][string]$File,
    [string]$OutFile
)

$alpha = [char[]]@(0x200A, 0x200B, 0x200C, 0x200F, 0x202F, 0x206A, 0x206B, 0x206C, 0x206D, 0x206E, 0x206F)
$sep = [char]0x2000
$prefix = ([string][char]0x2001) + ([string][char]0x2002)

function Decode-Invisible([string]$text) {
    if ($text.StartsWith($prefix)) { $text = $text.Substring(2) }
    $parts = $text.Split($sep)
    $bytes = New-Object System.Collections.Generic.List[byte]
    foreach ($p in $parts) {
        [double]$val = 0
        for ($i = 0; $i -lt $p.Length; $i++) {
            $digit = [Array]::IndexOf($alpha, $p[$p.Length - 1 - $i])
            if ($digit -lt 0) { throw "حرف غير معروف في الملف" }
            $val += $digit * [Math]::Pow(11, $i)
        }
        $bytes.Add([byte]([int]$val -band 0xFF))
    }
    return [System.Text.Encoding]::UTF8.GetString($bytes.ToArray())
}

function Encode-Invisible([string]$json) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $parts = foreach ($b in $bytes) {
        $v = [int]$b; $s = ''
        while ($v -gt 0) { $s = [string]$alpha[$v % 11] + $s; $v = [Math]::Floor($v / 11) }
        $s
    }
    return $prefix + ($parts -join $sep)
}

if ($Mode -eq 'decode') {
    $text = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
    $json = Decode-Invisible $text
    if (!$OutFile) { $OutFile = [System.IO.Path]::ChangeExtension($File, '.decoded.json') }
    [System.IO.File]::WriteAllText($OutFile, $json, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "تم الفك ✅ → $OutFile"
    Write-Host ("عدد السجلات: " + (($json | ConvertFrom-Json).PSObject.Properties.Count))
}
else {
    $json = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
    $encoded = Encode-Invisible $json
    if (!$OutFile) { $OutFile = [System.IO.Path]::ChangeExtension($File, '.bin') }
    [System.IO.File]::WriteAllText($OutFile, $encoded, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "تم التشفير ✅ → $OutFile"
}
