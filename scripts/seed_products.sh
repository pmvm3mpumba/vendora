#!/usr/bin/env bash
set -euo pipefail

# Données de démonstration uniquement. Les images HTTPS sont temporaires.
# Ce script utilise les droits gcloud de l'administrateur Firestore.
PROJECT_ID="${PROJECT_ID:-vendora-19a5c}"
TOKEN="$(gcloud auth print-access-token)"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

add_product() {
  local id="$1" name="$2" description="$3" price="$4" currency="$5"
  local category="$6" stock="$7" image="$8"

  curl -f -sS -X PATCH \
    "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/products/${id}" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary @- <<JSON
{
  "fields": {
    "name": {"stringValue": "${name}"},
    "description": {"stringValue": "${description}"},
    "priceMinor": {"integerValue": "${price}"},
    "currency": {"stringValue": "${currency}"},
    "categoryId": {"stringValue": "${category}"},
    "stock": {"integerValue": "${stock}"},
    "imageUrl": {"stringValue": "${image}"},
    "sellerId": {"stringValue": "demo-seller"},
    "sellerName": {"stringValue": "Boutique Vendora"},
    "sellerWhatsappNumber": {"stringValue": "+25770000000"},
    "isActive": {"booleanValue": true},
    "createdAt": {"timestampValue": "${NOW}"},
    "updatedAt": {"timestampValue": "${NOW}"}
  }
}
JSON
  printf 'Produit ajouté : %s\n' "$name"
}

add_product "casque-bluetooth" "Casque Bluetooth" \
  "Casque sans fil pour écouter de la musique au quotidien." \
  85000 BIF electronique 12 \
  "https://placehold.co/600x600/png?text=Casque"

add_product "sac-urbain" "Sac urbain" \
  "Sac pratique pour les déplacements et les études." \
  45000 BIF mode 8 \
  "https://placehold.co/600x600/png?text=Sac"

add_product "montre-classique" "Montre classique" \
  "Montre élégante pour tous les jours." \
  65000 BIF accessoires 5 \
  "https://placehold.co/600x600/png?text=Montre"

add_product "lampe-bureau" "Lampe de bureau" \
  "Lampe LED adaptée au travail et à la lecture." \
  38000 BIF maison 10 \
  "https://placehold.co/600x600/png?text=Lampe"

add_product "creme-visage" "Crème pour le visage" \
  "Soin quotidien pour la peau." \
  22000 BIF beaute 15 \
  "https://placehold.co/600x600/png?text=Beauté"

add_product "ballon-foot" "Ballon de football" \
  "Ballon pour entraînement et loisirs." \
  30000 BIF sport 7 \
  "https://placehold.co/600x600/png?text=Sport"

add_product "carnet-etude" "Carnet d'étude" \
  "Carnet pratique pour les notes et les révisions." \
  9000 BIF livres 20 \
  "https://placehold.co/600x600/png?text=Carnet"

add_product "panier-fruits" "Panier de fruits" \
  "Sélection de fruits pour la maison." \
  18000 BIF alimentation 6 \
  "https://placehold.co/600x600/png?text=Fruits"

printf '\nTerminé. Les images sont temporaires et destinées au développement.\n'
