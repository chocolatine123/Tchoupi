# Dump des mots de passe d'un poste de travail

Inspiré librement de l'outil LaZagne.

Lancer le script depuis une clé USB, puis placer les résultats obtenu dans le Dossier Dump que vous aurez créé dans le même repertoire que Exploitation.ps1

Tchoupi fait un dump du LSA puis récupère les mots de passe des navigateurs Firefox et Google. Enfin, il récupère les clés Wifi. Peut être lancé sans privilèges particuliers, mais alors on n’aura que les informations de l’utilisateur courant.
