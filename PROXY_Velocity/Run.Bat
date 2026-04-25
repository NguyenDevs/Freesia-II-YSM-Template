:start
chcp 65001
@echo off
title PROXY VELOCITY
java -Xms512M -Xmx512M -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity-3.4.0-SNAPSHOT-521.jar

echo Server restarting...
echo Press CTRL + C to stop.
goto :start