@echo off 
echo CREATION DE L'ENTREPRISE

dsadd ou "OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo Creation des Services d'entreprise
echo -----------------------------------

Echo Direction
dsadd ou "ou=Direction,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo Service Secretariat
dsadd ou "ou=Secretariat,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo Service Informatique
dsadd ou "ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo Equipe Developpement
dsadd ou "ou=Developpement,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo Equipe Service technique
dsadd ou "ou=Service_technique,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo ___________________________________
 
echo Creation des utilisateurs
echo -------------------------

echo Patron
dsadd user "cn=Patron,ou=Direction,OU=SIO,DC=aymeric,DC=sio,DC=com" -pwd P@ssw0rd2025! -disabled no -q

echo secretaire patron
dsadd user "cn=Secretaire,ou=Secretariat,OU=SIO,DC=aymeric,DC=sio,DC=com" -pwd P@ssw0rd2025! -disabled no -q

echo developpeur1
dsadd user "cn=Developpeur1,ou=Developpement,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -pwd P@ssw0rd2025! -disabled no -q

echo developpeur2
dsadd user "cn=Developpeur2,ou=Developpement,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -pwd P@ssw0rd2025! -disabled no -q

echo technicien informatique
dsadd user "cn=Technicien,ou=Service_technique,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -pwd P@ssw0rd2025! -disabled no -q

echo _________________________ 

echo Creation des groupes
echo --------------------

echo Groupe Administrateur : Admin
dsadd group "cn=Admin,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

Echo Groupe Direction : Directeur
dsadd group "cn=Directeur,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

Echo Groupe Developpement : Dev
dsadd group "cn=Dev,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

Echo Groupe Secretariat : Secre
dsadd group "cn=Secre,OU=SIO,DC=aymeric,DC=sio,DC=com" -q

echo ____________________

echo Deplacement des utilisateurs dans leur groupes
echo ----------------------------------------------

dsmod group "cn=Admin,OU=SIO,DC=aymeric,DC=sio,DC=com" -addmbr "cn=Technicien,ou=Service_technique,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q
echo Deplacement de Technicien vers groupe Admin

dsmod group "cn=Directeur,OU=SIO,DC=aymeric,DC=sio,DC=com" -addmbr "cn=Patron,ou=Direction,OU=SIO,DC=aymeric,DC=sio,DC=com" -q
echo Deplacement de Patron vers groupe Directeur

dsmod group "cn=Dev,OU=SIO,DC=aymeric,DC=sio,DC=com" -addmbr "cn=Developpeur1,ou=Developpement,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q
echo Deplacement de Developpeur1 vers groupe Dev

dsmod group "cn=Dev,OU=SIO,DC=aymeric,DC=sio,DC=com" -addmbr "cn=Developpeur2,ou=Developpement,ou=Informatique,OU=SIO,DC=aymeric,DC=sio,DC=com" -q
echo Deplacement de Developpeur2 vers groupe Dev

dsmod group "cn=Secre,OU=SIO,DC=aymeric,DC=sio,DC=com" -addmbr "cn=Secretaire,ou=Secretariat,OU=SIO,DC=aymeric,DC=sio,DC=com" -q
echo Deplacement de secretaire vers groupe Secre

echo ______________________________________________

set /p fin=Fin programme
@echo on