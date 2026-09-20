#!/usr/bin/env bash
# À exécuter depuis la racine du projet Flutter : bash generer_architecture.sh
# Crée uniquement les dossiers manquants, sans remplacer le code existant.
set -euo pipefail

if [[ ! -f pubspec.yaml || ! -f lib/main.dart ]]; then
  printf '%s\n' 'Erreur : lance ce script depuis la racine du projet Flutter (pubspec.yaml et lib/main.dart doivent exister).' >&2
  exit 1
fi

mkdir -p lib/app
mkdir -p lib/core/{theme,constants,errors,utils,validators,widgets}

for module in auth profile catalog seller_products cart checkout orders seller_dashboard whatsapp; do
  mkdir -p "lib/features/$module"/{models,data,providers,presentation/screens,presentation/widgets}
done

mkdir -p assets/{images,icons}
mkdir -p test/{unit,widgets}
mkdir -p integration_test
mkdir -p docs

# Git ne conserve pas les dossiers vides. Ajouter des marqueurs uniquement
# dans nos nouveaux dossiers ; ne pas modifier les dossiers générés Flutter.
while IFS= read -r -d '' directory; do
  touch "$directory/.gitkeep"
done < <(find lib/app lib/core lib/features assets test/unit test/widgets integration_test docs -type d -empty -print0)

printf '\n%s\n' 'Architecture créée. Aucun fichier Dart existant n’a été remplacé.'
printf '%s\n' 'Le code généré par Flutter reste exécutable.'
printf '\n%s\n' 'Dossiers du projet :'
find lib assets test integration_test docs -type d | sort