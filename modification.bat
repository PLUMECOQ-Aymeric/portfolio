@echo off
rem ============================================================
rem  modification.bat - TP10 Scripting et Active Directory
rem  1. Cree le dossier c:\dossier_partage\developpement
rem  2. Le partage sous le nom "developpement" avec les deux
rem     developpeurs de l'entreprise SIO
rem  3. Donne le controle total (NTFS) a l'administrateur local,
rem     au groupe dev et au groupe admin
rem  A lancer en ADMINISTRATEUR sur le serveur, apres creation.bat
rem ============================================================

rem --- Parametres ---------------------------------------------
set "DOSSIER=C:\dossier_partage\developpement"
set "PARTAGE=developpement"
rem  %USERDOMAIN% = nom NetBIOS du domaine (ex : DOMAINE)
set "NB=%USERDOMAIN%"

rem --- Verification des droits administrateur -----------------
net session >nul 2>&1
if errorlevel 1 (
    echo ERREUR : lancez ce script en tant qu'administrateur.
    pause
    exit /b 1
)

echo.
echo === 1/3 Creation du dossier ===
if not exist "%DOSSIER%" md "%DOSSIER%"

echo.
echo === 2/3 Partage du dossier avec les developpeurs ===
rem  On supprime un ancien partage du meme nom pour pouvoir relancer le script
net share %PARTAGE% >nul 2>&1 && net share %PARTAGE% /delete /y >nul
rem  /grant : droits sur le partage (acces reseau)
rem   - les 2 developpeurs (consigne du TP)
rem   - le groupe admin et le groupe Administrators (gestion)
net share %PARTAGE%="%DOSSIER%" /grant:%NB%\developpeur1,FULL /grant:%NB%\developpeur2,FULL /grant:%NB%\admin,FULL /grant:Administrators,FULL /remark:"Dossier partage des developpeurs SIO"

echo.
echo === 3/3 Droits NTFS (controle total) ===
rem  /inheritance:r : supprime les droits herites de C:\ (ex : lecture pour Users)
rem  (OI)(CI)F      : controle total, applique aux fichiers et sous-dossiers
rem  *S-1-5-32-544  : groupe local Administrateurs (SID, independant de la langue)
rem  *S-1-5-18      : SYSTEM (necessaire au bon fonctionnement de Windows)
icacls "%DOSSIER%" /inheritance:r /grant "*S-1-5-32-544:(OI)(CI)F" "*S-1-5-18:(OI)(CI)F" "%NB%\dev:(OI)(CI)F" "%NB%\admin:(OI)(CI)F"

echo.
echo Dossier cree, partage et droits appliques.
pause