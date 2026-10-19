<#
  rebuild-and-sign.ps1 — إعادة بناء وتوقيع نسخة أيوجرام المعدلة
  ─────────────────────────────────────────────────────────────
  الاستخدام (من داخل فولدر 04-ملفات-البناء):
      .\rebuild-and-sign.ps1
      .\rebuild-and-sign.ps1 -DecodedDir "C:\work\unpack-apktool" -Name "AyuGram-custom"

  الناتج:
      ..\03-النسخ-الجاهزة\<Name>.apk   (موقّع بكيستور AyuMod وجاهز للتثبيت)

  ملاحظة: التعديلات بتتعمل في السورس المفكوك (مجلد apktool-unpacked في 02)،
          وبعدها تشغّل السكربت ده عشان تطلع نسخة جديدة موقعة.
#>
param(
    [string]$DecodedDir = "C:\work\unpack-apktool",
    [string]$Name = "AyuGram-custom",
    [string]$JdkPath = "C:\Java\jdk17",
    [string]$BuildTools = "C:\Android\android-sdk\build-tools\37.0.0"
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$apktool = Join-Path $here "tools\apktool.jar"
$keystore = Join-Path $here "ayumod-release.jks"
$ksPass = "كلمة-السر-محفوظة-عند-صاحب-المشروع"
$ksAlias = "ayumod"
$outDir = Join-Path $here "..\03-النسخ-الجاهزة"
$work = Join-Path $here "..\_build"
New-Item -ItemType Directory -Force -Path $work | Out-Null

if (!(Test-Path $apktool)) { throw "مفيش tools\apktool.jar — تأكد إنك جوه مجلد 04-ملفات-البناء" }
if (!(Test-Path $DecodedDir)) { throw "مفيش مجلد السورس المفكوك: $DecodedDir" }

$env:JAVA_HOME = $JdkPath
$env:PATH = "$JdkPath\bin;$env:PATH"

Write-Host "[1/4] بناء الـAPK من: $DecodedDir ..." -ForegroundColor Cyan
& java -Xmx6g -jar $apktool b $DecodedDir -o "$work\$Name-unsigned.apk"
if ($LASTEXITCODE -ne 0) { throw "فشل البناء — بص على رسائل apktool فوق" }

Write-Host "[2/4] محاذاة (zipalign) ..." -ForegroundColor Cyan
& "$BuildTools\zipalign.exe" -f -p 4 "$work\$Name-unsigned.apk" "$work\$Name-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw "فشل المحاذاة" }

Write-Host "[3/4] توقيع (apksigner) ..." -ForegroundColor Cyan
& "$BuildTools\apksigner.bat" sign --ks $keystore --ks-pass "pass:$ksPass" --key-pass "pass:$ksPass" --ks-key-alias $ksAlias --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --out "$outDir\$Name.apk" "$work\$Name-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw "فشل التوقيع" }

Write-Host "[4/4] تحقق من التوقيع ..." -ForegroundColor Cyan
& "$BuildTools\apksigner.bat" verify --verbose "$outDir\$Name.apk"

$h = (Get-FileHash "$outDir\$Name.apk" -Algorithm SHA256).Hash
Write-Host ""
Write-Host "تم بنجاح ✅" -ForegroundColor Green
Write-Host "الملف:  $outDir\$Name.apk" -ForegroundColor Green
Write-Host "SHA-256: $h" -ForegroundColor Green
