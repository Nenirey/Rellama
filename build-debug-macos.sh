export PATH=/lamw/apache-ant-1.9.13/bin:$PATH
export JAVA_HOME=${/usr/libexec/java_home}
export PATH=${JAVA_HOME}/bin:$PATH
cd /lamw/lazandroidmodulewizard/demos/GUI/AppIntentDemo3/
ant -Dtouchtest.enabled=true debug
