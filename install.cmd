@echo off
rem Maze of Existence - instala/atualiza o jogo (Windows)
rem Uso: install.cmd [-Version v1.1.0] [-NoLaunch] [-NoShortcut] [-Uninstall]
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
