# Focus Flow
Focus Flow est une application Flutter de gestion de tâches et de sessions de concentration. Elle permet de planifier ses tâches, lancer des sessions de focus, suivre sa progression et utiliser l'application en français ou en anglais.

## Fonctionnalités

* Tableau de bord
* Gestion des tâches
* Sessions de concentration
* Suivi de la progression
* Paramètres
* Support français et anglais
* Interface responsive
* Accessibilité avec `Semantics`
* Navigation Material 3

## Tests

Le projet comprend une suite de tests couvrant les différentes parties de l'application :

* **12 tests unitaires** pour les repositories et la logique métier
* **5 tests de widgets** pour les écrans et la navigation
* **2 tests d'intégration** pour les parcours principaux

Pour exécuter les tests :

```bash
flutter test
```

Pour les tests d'intégration :

```bash
flutter test integration_test/app_test.dart -d linux
```

## Performance

L'application utilise :

* `ListView.builder` et `SliverList.builder` pour le chargement différé des listes ;
* des widgets `const` lorsque cela est possible ;
* un état local afin de limiter les rebuilds inutiles ;
* aucune image raster embarquée, l'application étant principalement basée sur du contenu textuel.

Les performances peuvent être vérifiées avec Flutter DevTools.

## Architecture

```text
lib/
├── models/
├── data/
├── l10n/
└── main.dart

test/
├── task_repository_test.dart
└── widget_test.dart

integration_test/
└── app_test.dart

.github/
└── workflows/
    └── ci.yml
```

La logique métier est séparée de la présentation grâce à une organisation basée sur les repositories.

## Installation

Cloner le projet :

```bash
git clone https://github.com/SouveraineMAB/flutter-production-ready.git
cd flutter-production-ready
```

Installer les dépendances :

```bash
flutter pub get
```

Lancer l'application :

```bash
flutter run
```

## Vérification

Avant une livraison, exécuter :

```bash
flutter analyze
flutter test
```

Une pipeline **GitHub Actions** vérifie automatiquement le formatage, l'analyse statique, les tests, les tests d'intégration et la génération de l'APK Android.

## Captures d'écran

Les captures d'écran de l'application sont disponibles dans :

```text
docs/screenshots/
```

## CHANGELOG

Les principales évolutions du projet sont documentées dans `CHANGELOG.md`, avec au minimum trois versions :

* `v1.0.0`
* `v1.1.0`
* `v1.2.0`

## Licence

Projet éducatif réalisé dans le cadre d'un projet Flutter orienté production.
