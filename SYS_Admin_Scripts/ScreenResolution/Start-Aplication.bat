@echo off

start C:\start-script\set-screen_resolution.ps1

start C:\sdk\spain\server\release\server.exe

start C:\sdk\spain\client\release\client.exe -noro -norl -nohw -mast -noi2c -bind 127.0.0.1 -ip 127.0.0.1
