# Conception du Réseau de Lecteurs

### 1. Le cahier des charges

#### Règles de gestion

**RG1 :** Un membre est identifié par une adresse e-mail, unique sur la plateforme. Il possède toujours un pseudonyme (mail ou autre) et une date d'inscription, et facultativement une biographie.

**RG2 :** Un livre est identifié par son code ISBN (unique). Il possède toujours un titre, un nombre de pages, un synopsis et une date de parution.

**RG3 :** Un livre appartient à exactement un genre littéraire principal (ex: Science-Fiction, Romance). Un genre peut classifier aucun ou plusieurs livres.

**RG4 :** Un livre est écrit par au moins un auteur, et peut être écrit par plusieurs auteurs. Un auteur enregistré dans la base a écrit au moins un livre.

**RG5 :** Un membre peut donner son avis sur un livre en publiant une critique. Il écrit au plus une critique par livre. Un livre reçoit aucune, une ou plusieurs critiques.

**RG6 :** Une critique contient toujours une note de 1 à 5, toujours une date de publication, et un texte de commentaire facultatif.

**RG7 :** Les membres peuvent se regrouper. Un club de lecture est identifié par un id technique. Il possède toujours un nom (unique) et une date de création.

**RG8 :** Un membre peut rejoindre aucun, un ou plusieurs clubs de lecture. Un club de lecture contient toujours au moins un membre (son fondateur).

**RG9 :** Pour l'aspect social, un membre peut suivre aucun, un ou plusieurs autres membres pour voir leur activité. Un membre peut être suivi par aucun, un ou plusieurs membres.

**RG10 :** Un membre peut ajouter un livre à sa bibliothèque personnelle. Ce faisant, il doit toujours renseigner un statut de lecture (ex: « à lire », « en cours », « lu ») et une date d'ajout.

### Questions au métier posées lors de la conception

**Question 1 :** Un auteur peut-il exister seul dans la base s'il n'a aucun livre référencé sur notre plateforme ?

**Réponse retenue :** Non. Nous avons décidé qu'un auteur n'est créé que s'il est rattaché à un livre. C'est ce qui justifie le « au moins un » du côté de l'auteur dans la RG4.

**Question 2 :** Si un membre supprime son compte, que deviennent ses critiques ?

**Réponse retenue :** Pour ne pas fausser la note moyenne d'un livre qui a été calculée dans le temps, les critiques restent, mais le compte de l'auteur de la critique passera en « Utilisateur supprimé ». Le MLD devra en tenir compte (pas de suppression en cascade dure).

![MCD](./docs/mcd.png)