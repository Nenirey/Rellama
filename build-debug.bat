set Path=%PATH%;C:\lamw\apache-ant-1.9.13\bin
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_181
cd C:\lamw\lazandroidmodulewizard\demos\GUI\AppIntentDemo3\
call ant clean -Dtouchtest.enabled=true debug
if errorlevel 1 pause
