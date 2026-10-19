@echo off
rem غلاف بسيط لتشغيل سكربت البناء والتوقيع من غير مشاكل سياسة التنفيذ
rem استخدم: اسحب أي APK هنا؟ لا — ده للبناء: دوس مرتين على الملف ده
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rebuild-and-sign.ps1" %*
pause
