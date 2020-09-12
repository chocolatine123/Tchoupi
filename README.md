# Dump des mots de passe d'un poste de travail

Inspiré librement de l'outil LaZagne.

Lancer le script depuis une clé USB, puis placer les résultats obtenu dans le Dossier Dump que vous aurez créé dans le même repertoire que Exploitation.ps1

Tchoupi fait un dump du LSA puis récupère les mots de passe des navigateurs Firefox et Google. Enfin, il récupère les clés Wifi. Peut être lancé sans privilèges particuliers, mais alors on n’aura que les informations de l’utilisateur courant.

Nécessite les outils PsExec et Procdump de la suite Sysinternals.

Nécessite de plus Chromme Password Decryptor, renommé en cp.exe.


Utilisation de l’outil :


Je branche la clé et lance un Shell administrateur (marche aussi en simple utilisateur, mais en toute logique, nous n’avons pas les informations contenues dans le LSA). Voici ce que nous trouvons à la racine de la clé :
  Le premier script : Tchoupi.ps1,
Le second en cas d’élévation de privilège : procdump.ps1,
Les outils de la suite Sysinternals : procdump.exe et PsExec.exe,
L’outil pour obtenir les mots de passe chrome : cp.exe.

Je lance ensuite le premier script. A la racine du domaine, nous avons un dossier créé par ordinateur analysé, nommé avec le hostname de ces derniers.
Dans chacun de ces dossiers, nous avons tout d’abord un dossier Data-Admin qui contient les données prises en tant qu’admin.
Chaque dossier correspond aux utilisateurs présents dans C:\Users et contiennent les bases de données Firefox avec clé et certificat associés :
 Nous avons ensuite un dossier Data-User, contenant des données ne nécessitant pas d’élévation de privilèges. Ces dernières sont les mots de passe Chrome de la session ouverte ainsi que les clés Wifi auxquelles le poste s’est déjà connecté. 
 
 Une fois l’action effectuée, déplacer tous les dossiers HOSTNAME dans un dossier intitulé Dump dans un PC dédié. Lancer ensuite un script exploitation.ps1. Nous obtenons alors les différentes bases SAM en clair à l’aide de l’outil Impacket et éventuellement les mots de passe Kerberos contenus dans la mémoire vive à l’aide de Mimikatz. Enfin, nous récupérons les mots de Firefox à l’aide du script python firefox_decrypt.py.
