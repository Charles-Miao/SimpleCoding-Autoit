chcp 437

:start


::ghost

ghost32 -clone,mode=load,src=Y:\QP200GA\QP200GA_ALL_IN_ONE.GHO,dst=1 -fdsp -ib -fnf -fx -auto -sure
if not errorlevel 1 goto end

:ghostng
echo ghost ng
pause>nul
goto start

:end