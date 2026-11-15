@echo off
rem ============================================================
rem  suppression.bat - TP10 Scripting et Active Directory
rem  Supprime tout ce qui a ete cree par creation.bat et
rem  modification.bat :
rem   1. le partage "developpement" et le dossier
rem      c:\dossier_partage\developpement
rem   2. l'UO racine SIO avec TOUT son contenu (sous-UO,
rem      utilisateurs, groupes)
rem  Option : suppression.bat /y  -> pas de demande de confirmation
rem  A lancer en ADMINISTRATEUR sur le controleur de domaine.
rem ============================================================

rem --- Parametres (memes valeurs que creation.bat) -------------
set "DN=DC=Domaine,DC=com"
set "SIO=OU=SIO,%DN%"
set "DOSSIER=C:\dossier_partage\developpement"
set "PARTAGE=developpement"

rem --- Verification des droits administrateur -----------------
net session >nul 2>&1
if errorlevel 1 (
    echo ERREUR : lancez ce script en tant qu'administrateur.
    pause
    exit /b 1
)

rem --- Confirmation (sauf si l'option /y est passee) ----------
if /i "%~1"=="/y" goto :suite
echo ATTENTION : cette operation supprime definitivement l'UO SIO
echo et tout son contenu, ainsi que le dossier partage developpement.
choice /c ON /m "Continuer (O = Oui, N = Non)"
if errorlevel 2 (
    echo Operation annulee.
    exit /b 0
)

:suite
echo.
echo === 1/2 Suppression du partage et du dossier ===
rem  Le partage est supprime avant le dossier
net share %PARTAGE% >nul 2>&1 && net share %PARTAGE% /delete /y
if exist "%DOSSIER%" rd /s /q "%DOSSIER%"
rem  Supprime aussi c:\dossier_partage s'il est vide (rd refuse sinon)
rd "C:\dossier_partage" >nul 2>&1

echo.
echo === 2/2 Suppression de l'UO SIO et de tout son contenu ===
rem  -subtree : supprime l'objet et toute son arborescence
rem  -noprompt : pas de confirmation de dsrm
dsrm -subtree -noprompt "%SIO%"

echo.
echo Suppression terminee.
pause