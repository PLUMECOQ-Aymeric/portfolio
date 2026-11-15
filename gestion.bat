@echo off
setlocal
rem ============================================================
rem  gestion_AD.bat - TP10 Scripting et Active Directory
rem  Menu de gestion complete d'un Active Directory.
rem
rem  ARBORESCENCE DES ACTIONS
rem   1 Structure et dossier partage
rem     1.1 Creer la structure complete SIO        (creation.bat)
rem     1.2 Creer le dossier partage et les droits (modification.bat)
rem   2 Unites d'organisation
rem     2.1 Creer une UO
rem     2.2 Afficher l'arborescence de l'UO SIO
rem   3 Utilisateurs
rem     3.1 Creer la liste du personnel (fichier personnels.csv)
rem     3.2 Afficher la liste du personnel
rem     3.3 Importer la liste du personnel dans l'AD
rem     3.4 Creer un utilisateur
rem     3.5 Deplacer un utilisateur vers une autre UO
rem     3.6 Reinitialiser un mot de passe
rem     3.7 Activer ou desactiver un compte
rem     3.8 Lister les utilisateurs
rem   4 Groupes
rem     4.1 Creer un groupe
rem     4.2 Ajouter un utilisateur a un groupe
rem     4.3 Afficher les membres d'un groupe
rem     4.4 Afficher les groupes d'un utilisateur
rem   5 Ordinateurs
rem     5.1 Declarer un ordinateur
rem     5.2 Lister les ordinateurs
rem   6 Recherches et exports
rem     6.1 Rechercher des utilisateurs par nom
rem     6.2 Exporter les utilisateurs en CSV (csvde)
rem   7 Gestion des suppressions
rem     7.1 Supprimer un utilisateur
rem     7.2 Supprimer un groupe
rem     7.3 Supprimer une UO et tout son contenu
rem     7.4 Supprimer un ordinateur
rem     7.5 Supprimer le dossier partage
rem     7.6 Nettoyage complet de l'AD (suppression.bat)
rem   0 Quitter
rem
rem  Les scripts creation.bat, modification.bat et suppression.bat
rem  doivent etre dans le meme dossier que ce script.
rem  A lancer en ADMINISTRATEUR sur le controleur de domaine.
rem ============================================================

rem --- Parametres a adapter (memes valeurs que creation.bat) ---
set "DOMAINE=Domaine.com"
set "DN=DC=Domaine,DC=com"
set "MDP=Sio@2026!"
set "SIO=OU=SIO,%DN%"
set "FICHIER=%~dp0personnels.csv"
set "DOSSIER=C:\dossier_partage\developpement"
set "PARTAGE=developpement"

rem --- Verification des droits administrateur -----------------
net session >nul 2>&1
if errorlevel 1 (
    echo ERREUR : lancez ce script en tant qu'administrateur.
    pause
    exit /b 1
)

rem ============================================================
rem  MENU PRINCIPAL
rem ============================================================
:menu
cls
echo ====== GESTION ACTIVE DIRECTORY - %DOMAINE% ======
echo.
echo  1  Structure et dossier partage
echo  2  Unites d'organisation
echo  3  Utilisateurs
echo  4  Groupes
echo  5  Ordinateurs
echo  6  Recherches et exports
echo  7  Gestion des suppressions
echo  0  Quitter
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto m1
if "%C%"=="2" goto m2
if "%C%"=="3" goto m3
if "%C%"=="4" goto m4
if "%C%"=="5" goto m5
if "%C%"=="6" goto m6
if "%C%"=="7" goto m7
if "%C%"=="0" exit /b 0
goto menu

rem ============================================================
rem  1 - STRUCTURE ET DOSSIER PARTAGE
rem ============================================================
:m1
cls
echo ====== 1. STRUCTURE ET DOSSIER PARTAGE ======
echo.
echo  1  Creer la structure complete SIO
echo  2  Creer le dossier partage et les droits
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" call "%~dp0creation.bat"
if "%C%"=="2" call "%~dp0modification.bat"
if "%C%"=="0" goto menu
goto m1

rem ============================================================
rem  2 - UNITES D'ORGANISATION
rem ============================================================
:m2
cls
echo ====== 2. UNITES D'ORGANISATION ======
echo.
echo  1  Creer une UO
echo  2  Afficher l'arborescence de l'UO SIO
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a21
if "%C%"=="2" goto a22
if "%C%"=="0" goto menu
goto m2

:a21
rem  Cree une UO sous SIO ou sous une UO parente choisie
set "NOM="
set /p "NOM=Nom de la nouvelle UO : "
set "PAR="
set /p "PAR=Nom de l'UO parente [vide = SIO] : "
set "PARDN=%SIO%"
if defined PAR set "OUNOM=%PAR%"
if defined PAR call :trouver_ou
if defined PAR if not defined OUDN goto fin21
if defined PAR set "PARDN=%OUDN%"
dsadd ou "OU=%NOM%,%PARDN%"
:fin21
pause
goto m2

:a22
dsquery * "%SIO%" -scope subtree -attr name objectClass
pause
goto m2

rem ============================================================
rem  3 - UTILISATEURS
rem ============================================================
:m3
cls
echo ====== 3. UTILISATEURS ======
echo.
echo  1  Creer la liste du personnel (ajouter une personne au fichier)
echo  2  Afficher la liste du personnel
echo  3  Importer la liste du personnel dans l'AD
echo  4  Creer un utilisateur
echo  5  Deplacer un utilisateur vers une autre UO
echo  6  Reinitialiser un mot de passe
echo  7  Activer ou desactiver un compte
echo  8  Lister les utilisateurs
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a31
if "%C%"=="2" goto a32
if "%C%"=="3" goto a33
if "%C%"=="4" goto a34
if "%C%"=="5" goto a35
if "%C%"=="6" goto a36
if "%C%"=="7" goto a37
if "%C%"=="8" goto a38
if "%C%"=="0" goto menu
goto m3

:a31
rem  Ajoute une ligne au fichier personnels.csv
rem  Format : prenom;nom;identifiant;UO;groupe   (5 champs obligatoires)
set "P="
set /p "P=Prenom : "
set "N="
set /p "N=Nom : "
set "S="
set /p "S=Identifiant de connexion, 20 caracteres maximum : "
set "O="
set /p "O=Nom de l'UO : "
set "G="
set /p "G=Identifiant du groupe : "
>>"%FICHIER%" echo %P%;%N%;%S%;%O%;%G%
echo Ajoute dans %FICHIER%
pause
goto m3

:a32
if exist "%FICHIER%" (type "%FICHIER%") else echo Aucun fichier de personnel pour le moment.
pause
goto m3

:a33
rem  Cree dans l'AD chaque personne du fichier personnels.csv
if not exist "%FICHIER%" echo Aucun fichier de personnel.
if not exist "%FICHIER%" goto fin33
for /f "usebackq tokens=1-5 delims=;" %%a in ("%FICHIER%") do call :importer "%%a" "%%b" "%%c" "%%d" "%%e"
:fin33
pause
goto m3

:a34
set "P="
set /p "P=Prenom : "
set "N="
set /p "N=Nom : "
set "S="
set /p "S=Identifiant de connexion : "
set "OUNOM="
set /p "OUNOM=Nom de l'UO : "
call :trouver_ou
if not defined OUDN goto fin34
dsadd user "CN=%P% %N%,%OUDN%" -samid %S% -upn %S%@%DOMAINE% -fn "%P%" -ln "%N%" -display "%P% %N%" -pwd %MDP% -disabled no -pwdneverexpires yes
:fin34
pause
goto m3

:a35
set "S="
set /p "S=Identifiant de l'utilisateur : "
call :trouver_user
if not defined USERDN goto fin35
set "OUNOM="
set /p "OUNOM=Nom de l'UO de destination : "
call :trouver_ou
if not defined OUDN goto fin35
dsmove "%USERDN%" -newparent "%OUDN%"
:fin35
pause
goto m3

:a36
set "S="
set /p "S=Identifiant de l'utilisateur : "
call :trouver_user
if not defined USERDN goto fin36
set "NP="
set /p "NP=Nouveau mot de passe : "
rem  -mustchpwd yes : l'utilisateur doit le changer a la prochaine connexion
dsmod user "%USERDN%" -pwd "%NP%" -mustchpwd yes
:fin36
pause
goto m3

:a37
set "S="
set /p "S=Identifiant de l'utilisateur : "
call :trouver_user
if not defined USERDN goto fin37
choice /c AD /m "A = Activer, D = Desactiver"
if errorlevel 2 dsmod user "%USERDN%" -disabled yes
if not errorlevel 2 dsmod user "%USERDN%" -disabled no
:fin37
pause
goto m3

:a38
dsquery user "%SIO%" -limit 0 | dsget user -samid -upn -disabled
pause
goto m3

rem ============================================================
rem  4 - GROUPES
rem ============================================================
:m4
cls
echo ====== 4. GROUPES ======
echo.
echo  1  Creer un groupe
echo  2  Ajouter un utilisateur a un groupe
echo  3  Afficher les membres d'un groupe
echo  4  Afficher les groupes d'un utilisateur
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a41
if "%C%"=="2" goto a42
if "%C%"=="3" goto a43
if "%C%"=="4" goto a44
if "%C%"=="0" goto menu
goto m4

:a41
set "GRP="
set /p "GRP=Nom du groupe : "
dsadd group "CN=%GRP%,%SIO%" -samid %GRP% -secgrp yes -scope g
pause
goto m4

:a42
set "GRP="
set /p "GRP=Identifiant du groupe : "
call :trouver_groupe
if not defined GRPDN goto fin42
set "S="
set /p "S=Identifiant de l'utilisateur : "
call :trouver_user
if not defined USERDN goto fin42
dsmod group "%GRPDN%" -addmbr "%USERDN%"
:fin42
pause
goto m4

:a43
set "GRP="
set /p "GRP=Identifiant du groupe : "
call :trouver_groupe
if not defined GRPDN goto fin43
dsget group "%GRPDN%" -members -expand
:fin43
pause
goto m4

:a44
set "S="
set /p "S=Identifiant de l'utilisateur : "
call :trouver_user
if not defined USERDN goto fin44
dsget user "%USERDN%" -memberof -expand
:fin44
pause
goto m4

rem ============================================================
rem  5 - ORDINATEURS
rem ============================================================
:m5
cls
echo ====== 5. ORDINATEURS ======
echo.
echo  1  Declarer un ordinateur
echo  2  Lister les ordinateurs
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a51
if "%C%"=="2" goto a52
if "%C%"=="0" goto menu
goto m5

:a51
set "PC="
set /p "PC=Nom de l'ordinateur : "
dsadd computer "CN=%PC%,CN=Computers,%DN%"
pause
goto m5

:a52
dsquery computer "%DN%"
pause
goto m5

rem ============================================================
rem  6 - RECHERCHES ET EXPORTS
rem ============================================================
:m6
cls
echo ====== 6. RECHERCHES ET EXPORTS ======
echo.
echo  1  Rechercher des utilisateurs par debut de nom
echo  2  Exporter les utilisateurs en CSV
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a61
if "%C%"=="2" goto a62
if "%C%"=="0" goto menu
goto m6

:a61
set "MOTIF="
set /p "MOTIF=Debut du nom : "
dsquery user "%DN%" -name %MOTIF%* | dsget user -samid -fn -ln -upn
pause
goto m6

:a62
rem  csvde : exporte les utilisateurs du domaine dans utilisateurs.csv
csvde -f "%~dp0utilisateurs.csv" -d "%DN%" -r "(objectClass=user)" -l "DN,sAMAccountName,givenName,sn,userPrincipalName"
echo Fichier : %~dp0utilisateurs.csv
pause
goto m6

rem ============================================================
rem  7 - GESTION DES SUPPRESSIONS
rem ============================================================
:m7
cls
echo ====== 7. GESTION DES SUPPRESSIONS ======
echo.
echo  1  Supprimer un utilisateur
echo  2  Supprimer un groupe
echo  3  Supprimer une UO et tout son contenu
echo  4  Supprimer un ordinateur
echo  5  Supprimer le dossier partage
echo  6  Nettoyage complet de l'AD
echo  0  Retour
echo.
set "C="
set /p "C=Votre choix : "
if "%C%"=="1" goto a71
if "%C%"=="2" goto a72
if "%C%"=="3" goto a73
if "%C%"=="4" goto a74
if "%C%"=="5" goto a75
if "%C%"=="6" goto a76
if "%C%"=="0" goto menu
goto m7

:a71
set "S="
set /p "S=Identifiant de l'utilisateur a supprimer : "
call :trouver_user
if not defined USERDN goto fin71
dsrm -noprompt "%USERDN%"
:fin71
pause
goto m7

:a72
set "GRP="
set /p "GRP=Identifiant du groupe a supprimer : "
call :trouver_groupe
if not defined GRPDN goto fin72
dsrm -noprompt "%GRPDN%"
:fin72
pause
goto m7

:a73
set "OUNOM="
set /p "OUNOM=Nom de l'UO a supprimer : "
call :trouver_ou
if not defined OUDN goto fin73
choice /c ON /m "Supprimer cette UO et tout son contenu (O = Oui, N = Non)"
if errorlevel 2 goto fin73
dsrm -subtree -noprompt "%OUDN%"
:fin73
pause
goto m7

:a74
set "PC="
set /p "PC=Nom de l'ordinateur a supprimer : "
dsrm -noprompt "CN=%PC%,CN=Computers,%DN%"
pause
goto m7

:a75
net share %PARTAGE% /delete /y
if exist "%DOSSIER%" rd /s /q "%DOSSIER%"
pause
goto m7

:a76
rem  Nettoyage complet : suppression.bat redemande une confirmation
call "%~dp0suppression.bat"
goto m7

rem ============================================================
rem  SOUS-PROGRAMMES
rem ============================================================

:trouver_ou
rem  Entree : OUNOM   Sortie : OUDN (DN complet de l'UO, vide si absente)
set "OUDN="
for /f "delims=" %%i in ('dsquery ou "%DN%" -name "%OUNOM%"') do set "OUDN=%%~i"
if not defined OUDN echo UO introuvable : %OUNOM%
exit /b

:trouver_user
rem  Entree : S (identifiant)   Sortie : USERDN
set "USERDN="
for /f "delims=" %%i in ('dsquery user "%DN%" -samid "%S%"') do set "USERDN=%%~i"
if not defined USERDN echo Utilisateur introuvable : %S%
exit /b

:trouver_groupe
rem  Entree : GRP (identifiant)   Sortie : GRPDN
set "GRPDN="
for /f "delims=" %%i in ('dsquery group "%DN%" -samid "%GRP%"') do set "GRPDN=%%~i"
if not defined GRPDN echo Groupe introuvable : %GRP%
exit /b

:importer
rem  Cree un utilisateur a partir d'une ligne du fichier personnels.csv
rem  Arguments : 1 prenom, 2 nom, 3 identifiant, 4 UO, 5 groupe
set "P=%~1"
set "N=%~2"
set "S=%~3"
set "OUNOM=%~4"
set "GRP=%~5"
call :trouver_ou
if not defined OUDN exit /b
dsadd user "CN=%P% %N%,%OUDN%" -samid %S% -upn %S%@%DOMAINE% -fn "%P%" -ln "%N%" -display "%P% %N%" -pwd %MDP% -disabled no -pwdneverexpires yes
call :trouver_groupe
if not defined GRPDN exit /b
dsmod group "%GRPDN%" -addmbr "CN=%P% %N%,%OUDN%"
exit /b