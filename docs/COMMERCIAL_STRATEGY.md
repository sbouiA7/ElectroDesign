# ElectroDesign — stratégie commerciale et intégration

**Statut :** proposition de produit à valider et plan d'intégration. Ce document ne signifie pas que la facturation ou les licences sont déjà implémentées.

## 1. Décision commerciale

ElectroDesign adopte un modèle **hybride Freemium** pour la **Tunisie et l'international** :

- une édition gratuite durable pour découvrir le logiciel, apprendre et réaliser des projets simples ;
- des éditions payantes pour les usages professionnels avancés ;
- à terme, des abonnements et une licence permanente, selon les marchés et les coûts de maintenance.

Le gratuit doit être réellement utile, et non une simple démonstration. Les limites doivent être annoncées clairement avant qu'un utilisateur commence un travail.

## 2. Gamme proposée

Les noms et le périmètre exacts sont à confirmer par des tests auprès d'utilisateurs.

| Édition | Public | Périmètre proposé |
|---|---|---|
| **Free** | Débutants, étudiants, découverte | Formation de base, exercices, bibliothèque de démarrage, projets et schémas simples, consultation et export de base avec limites clairement affichées |
| **Pro** | Électriciens, techniciens, installateurs, indépendants | Projets professionnels, schémas avancés, métrés, calculs disponibles et documentés, devis/factures, exports professionnels, bibliothèque étendue |
| **Expert** | Bureaux d'études, ingénieurs, intégrateurs | Fonctions Pro, tableaux 2D/3D, génération depuis schéma, contrôles avancés, rapports détaillés et outils de gestion de projets |
| **Équipe / Entreprise** (phase ultérieure) | Sociétés et bureaux d'études | Gestion multi-utilisateurs, partage de projets, rôles, administration des licences et support adapté |

Ne pas réserver les fonctions de sécurité indispensables à une formule payante : toute alerte de risque déjà calculable doit rester visible. Les éditions payantes peuvent apporter des contrôles supplémentaires, des rapports et des flux de travail plus avancés, sans masquer un danger connu.

## 3. Modes de commercialisation

1. **Abonnement mensuel et annuel** pour Pro et Expert, avec renouvellement et résiliation transparents.
2. **Licence permanente** proposée lorsque le périmètre et le coût de maintenance sont maîtrisés. Préciser la version incluse, la durée des mises à jour et les conditions de support.
3. **Licence entreprise** et devis sur demande pour les besoins multi-postes.
4. Éventuellement, tarifs étudiants ou éducatifs après validation du modèle économique.

Ne pas fixer les prix maintenant. Les tarifs commerciaux seront étudiés séparément pour la Tunisie et les marchés internationaux, avec devise, taxes, frais de paiement et pouvoir d'achat local pris en compte. Aucun tarif ne doit être présenté comme définitif sans décision explicite du propriétaire du produit.

## 4. Politique Tunisie et international

- Au premier lancement, proposer le pays comme suggestion et demander confirmation ; laisser le choix manuel.
- Adapter la devise et les moyens de paiement aux pays effectivement pris en charge. Ne pas supposer qu'un moyen de paiement international est disponible en Tunisie.
- Étudier les prestataires et obligations applicables pays par pays avant d'activer les paiements.
- Afficher le prix final, la périodicité, les taxes éventuelles, le renouvellement, la résiliation et les conditions de remboursement avant confirmation.
- Prévoir français et arabe en priorité pour le marché tunisien, puis anglais et autres langues selon la feuille de route.
- Ne pas confondre prix d'abonnement logiciel et tarifs de matériaux/main-d'œuvre des devis : ces derniers restent saisis et modifiables par l'utilisateur, sans devise ni prix imposés.

## 5. Licence et droits d'accès — conception technique

Créer une couche indépendante de l'interface :

- **ProductPlan** : Free, Pro, Expert, Team.
- **Entitlement** : droit d'accès à une capacité, avec état, origine, dates de validité et limites éventuelles.
- **LicenseAccount** : compte ou identifiant de licence, sans stocker de données de paiement sensibles dans l'application.
- **Subscription / Purchase** : référence au prestataire de paiement ou à la boutique, état et dates ; la source de vérité de paiement reste le prestataire.
- **FeatureCatalog** : identifiants stables des fonctions et édition minimale requise.
- **LicenseCache** : droits signés et vérifiables localement pour permettre l'utilisation hors connexion.

Principes obligatoires :
- Le contrôle des droits doit être centralisé dans un service d'accès, et non dispersé dans les widgets.
- Utiliser des jetons de licence signés côté serveur et une vérification cryptographique côté application. Ne jamais embarquer de clé privée de signature dans l'application.
- Prévoir une période hors connexion configurable et raisonnable, une date de dernière validation, un renouvellement lorsqu'une connexion est disponible et des messages compréhensibles en cas d'expiration.
- Ne jamais effacer, verrouiller ou rendre illisibles les projets de l'utilisateur à cause d'une licence expirée. Permettre au minimum l'ouverture, la consultation et l'export des données dans un format de récupération lorsque cela est techniquement possible.
- Prévoir restauration d'achat, changement d'appareil, révocation en cas de fraude avérée, support et procédure de récupération.
- Ne pas collecter plus de données personnelles que nécessaire. Protéger les échanges et les données locales.
- Les limites Free (nombre de projets, exports ou autres) doivent être explicites, raisonnables et testées ; ne jamais perdre le travail en cours lorsqu'une limite est atteinte.
- Les fonctions essentielles hors ligne doivent rester disponibles conformément aux droits mis en cache.

## 6. Architecture applicative proposée

Créer progressivement des composants isolés, testables et remplaçables :

- `PlanId` et `FeatureId` dans le domaine ;
- `EntitlementRepository` pour lire les droits actifs ;
- `AccessPolicy` pour décider si une fonction est accessible ;
- `LicenseProvider` pour la validation et la synchronisation ;
- `PurchaseProvider` abstrait pour brancher ultérieurement un prestataire ou une boutique adaptée à chaque plateforme et pays ;
- `LicenseStorage` sécurisé pour les jetons signés et leur état hors ligne.

Les modules métier demandent une autorisation via `AccessPolicy`. Ils ne doivent pas dépendre directement d'un fournisseur de paiement. Garder le mode gratuit utilisable sans création de compte obligatoire, si possible.

## 7. Parcours utilisateur et conversion

1. L'utilisateur choisit Débutant, Étudiant ou Professionnel ; ce choix adapte l'aide, pas ses droits commerciaux.
2. Il peut commencer avec Free sans carte bancaire.
3. Lorsqu'il utilise une fonction Pro/Expert, afficher une explication de sa valeur, les conditions et les options disponibles, sans interrompre ni perdre son travail.
4. Proposer une période d'essai uniquement si sa durée, ses conditions et sa conversion éventuelle sont clairement indiquées.
5. Après achat, activer les droits et confirmer leur état.
6. En cas de problème de paiement ou de réseau, expliquer la situation et proposer une récupération ; ne jamais simuler une activation.

## 8. Feuille de route commerciale et technique

### Étape A — Décisions produit
- Valider les noms Free / Pro / Expert / Entreprise.
- Définir précisément chaque fonctionnalité et ses limites.
- Étudier les utilisateurs cibles en Tunisie et dans quelques marchés internationaux prioritaires.
- Établir coûts de support, développement, distribution, paiement et fiscalité.
- Définir les conditions d'utilisation, confidentialité, licence, remboursement et support avec un conseil compétent selon les pays.

### Étape B — Préparer le code sans paiement réel
- Ajouter les modèles de plans, fonctions et droits.
- Implémenter un `AccessPolicy` avec un mode de développement/test.
- Protéger les fonctions par identifiants stables.
- Écrire des tests : Free/Pro/Expert, expiration, absence de réseau, droits incohérents, restauration et conservation des projets.
- Garder toutes les fonctions existantes accessibles pendant la migration.

### Étape C — Prototype de licence
- Développer un service de licence minimal avec jetons signés.
- Tester activation, renouvellement, expiration, révocation et fonctionnement hors ligne.
- Ne pas intégrer de paiement réel avant validation de la sécurité et des parcours.

### Étape D — Lancement commercial
- Choisir les prestataires de paiement compatibles avec la Tunisie et les pays ciblés, après vérification juridique et technique.
- Ajouter paiement, facturation, restauration et support.
- Lancer d'abord un pilote auprès d'utilisateurs tunisiens, corriger les problèmes, puis étendre progressivement à l'international.

## 9. Indicateurs à suivre

- Utilisateurs actifs Free et conversion vers Pro/Expert.
- Activation et renouvellement des licences.
- Rétention et utilisation des fonctions clés.
- Taux d'échec des paiements et demandes de remboursement.
- Tickets de support, erreurs de licence et incidents hors connexion.
- Satisfaction des étudiants et professionnels, par pays.

## 10. Décisions non prises

Aucun prix, devise par défaut, prestataire de paiement, durée d'essai, limite chiffrée Free ou condition contractuelle n'est fixé dans ce document. Ces décisions nécessitent des recherches de marché, des vérifications réglementaires et l'accord du propriétaire du produit.

## 11. Première priorité recommandée

Avant d'ajouter un système de paiement, stabiliser la base Flutter et ses compilations Android/Windows. Ensuite, intégrer le catalogue de fonctionnalités et le contrôle d'accès testable, sans paiement réel. Cela permet de concevoir les éditions commerciales sans fragiliser l'éditeur, les projets ni le fonctionnement hors ligne.
