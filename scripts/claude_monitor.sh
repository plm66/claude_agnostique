#!/bin/bash

# Usage: ./check_limite.sh [nombre_messages]
# Par défaut: 10 messages

MESSAGES=${1:-10}
TOKENS_PAR_MESSAGE=8000  # Pour du code
MAX_TOKENS=200000

TOKENS_UTILISES=$((MESSAGES * TOKENS_PAR_MESSAGE))
POURCENTAGE=$((TOKENS_UTILISES * 100 / MAX_TOKENS))

echo "Messages: $MESSAGES"
echo "Utilisé: $POURCENTAGE%"

if [ $POURCENTAGE -gt 90 ]; then
  echo "🚨 DANGER - LIMITE CRITIQUE!"
  echo "Créer IMMÉDIATEMENT TRANSITION_NOTES.md"
elif [ $POURCENTAGE -gt 80 ]; then
  echo "⚠️  Attention - Approche de la limite"
elif [ $POURCENTAGE -gt 60 ]; then
  echo "📊 Surveillance active"
else
  echo "✅ OK"
fi