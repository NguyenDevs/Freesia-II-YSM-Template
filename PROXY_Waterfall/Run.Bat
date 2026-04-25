:start
chcp 65001
@echo off
title PROXY WATERFALL
java -Xms512M -Xmx512M -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar waterfall-1.21-600.jar

echo Server restarting...
echo Press CTRL + C to stop.
goto :start