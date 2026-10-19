<#
  decode-apk.ps1 — فك أي APK (نسخة أحدث مستقبلًا أو أي تطبيق تاني)
  الاستخدام:
      .\decode-apk.ps1 -Apk "C:\path\to\file.apk"
      .\decode-apk.ps1 -Apk "C:\path\to\file.apk" -OutDir "C:\work\unpack2"
#>
param(
    [Parameter(Mandatory=$true)][string]$Apk,
    [string]$OutDir = "C:\work\unpack-apktool",
    [string]$JdkPath = "C:\Java\jdk17"
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$apktool = Join-Path $here "tools\apktool.jar"
$env:JAVA_HOME = $JdkPath
$env:PATH = "$JdkPath\bin;$env:PATH"

Write-Host "[apktool] فك الـAPK: $Apk" -ForegroundColor Cyan
& java -Xmx6g -jar $apktool d $Apk -o $OutDir -f
if ($LASTEXITCODE -ne 0) { throw "فشل فك الـAPK" }
Write-Host "خلص ✅ — السورس المفكوك في: $OutDir" -ForegroundColor Green
Write-Host ""
Write-Host "لقراءة الكود بجافا (مستحسن):" -ForegroundColor Yellow
Write-Host "  tools\jadx\bin\jadx-gui.bat  ثم افتح الـAPK الأصلي"
Write-Host "  أو من سطر أوامر: tools\jadx\bin\jadx.bat -d C:\work\unpack-jadx-new `"$Apk`""
