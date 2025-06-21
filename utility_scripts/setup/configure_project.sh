#!/bin/bash

# Script de configuration automatique du framework Claude
# Usage: ./configure_project.sh [project_type] [project_path]

set -e

# Configuration par défaut
DEFAULT_PROJECT_TYPE="fastapi_nextjs"
DEFAULT_PROJECT_PATH=$(pwd)

# Arguments
PROJECT_TYPE=${1:-$DEFAULT_PROJECT_TYPE}
PROJECT_PATH=${2:-$DEFAULT_PROJECT_PATH}
FRAMEWORK_PATH=$(dirname $(dirname $(dirname $(realpath $0))))

echo "🚀 Configuration du Framework Claude Agnostique"
echo "=============================================="
echo "Type de projet: $PROJECT_TYPE"
echo "Chemin du projet: $PROJECT_PATH"
echo "Framework source: $FRAMEWORK_PATH"
echo ""

# Vérifier que le type de projet existe
TEMPLATE_FILE="$FRAMEWORK_PATH/config/templates/${PROJECT_TYPE}.json"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Erreur: Template '$PROJECT_TYPE' non trouvé"
    echo "Templates disponibles:"
    ls -1 "$FRAMEWORK_PATH/config/templates/" | sed 's/.json$//' | sed 's/^/  - /'
    exit 1
fi

# Vérifier que le projet existe
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Erreur: Répertoire projet '$PROJECT_PATH' non trouvé"
    exit 1
fi

# Fonction pour demander confirmation
confirm() {
    read -p "$1 (y/N): " response
    case $response in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Fonction pour demander une valeur avec défaut
ask_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    
    read -p "$prompt [$default]: " value
    if [ -z "$value" ]; then
        value="$default"
    fi
    eval "$varname='$value'"
}

echo "📋 Collecte des informations du projet"
echo "========================================"

# Détecter le nom du projet depuis le chemin
PROJECT_NAME=$(basename "$PROJECT_PATH")
ask_with_default "Nom du projet" "$PROJECT_NAME" PROJECT_NAME

# Détecter l'utilisateur actuel
CURRENT_USER=$(whoami)
ask_with_default "Nom d'utilisateur" "$CURRENT_USER" PROJECT_USER

# Chemins absolus
PROJECT_ROOT_PATH=$(realpath "$PROJECT_PATH")
if [ "${PROJECT_ROOT_PATH: -1}" != "/" ]; then
    PROJECT_ROOT_PATH="${PROJECT_ROOT_PATH}/"
fi

# Configuration des ports selon le type de projet
case $PROJECT_TYPE in
    "fastapi_nextjs")
        DEFAULT_BACKEND_PORT=8000
        DEFAULT_FRONTEND_PORT=3000
        DEFAULT_DB_TYPE="postgresql"
        DEFAULT_BACKEND_COMMAND="cd backend && poetry run uvicorn app.main:app --reload --port 8000"
        DEFAULT_FRONTEND_COMMAND="cd frontend && npm run dev"
        ;;
    "django_react")
        DEFAULT_BACKEND_PORT=8000
        DEFAULT_FRONTEND_PORT=3000
        DEFAULT_DB_TYPE="postgresql"
        DEFAULT_BACKEND_COMMAND="cd backend && python manage.py runserver 8000"
        DEFAULT_FRONTEND_COMMAND="cd frontend && npm start"
        ;;
    "node_express")
        DEFAULT_BACKEND_PORT=3000
        DEFAULT_FRONTEND_PORT=""
        DEFAULT_DB_TYPE="mongodb"
        DEFAULT_BACKEND_COMMAND="npm run dev"
        DEFAULT_FRONTEND_COMMAND=""
        ;;
    *)
        DEFAULT_BACKEND_PORT=8000
        DEFAULT_FRONTEND_PORT=3000
        DEFAULT_DB_TYPE="postgresql"
        DEFAULT_BACKEND_COMMAND="npm start"
        DEFAULT_FRONTEND_COMMAND="npm run dev"
        ;;
esac

ask_with_default "Port backend" "$DEFAULT_BACKEND_PORT" BACKEND_PORT

if [ "$PROJECT_TYPE" != "node_express" ]; then
    ask_with_default "Port frontend" "$DEFAULT_FRONTEND_PORT" FRONTEND_PORT
else
    FRONTEND_PORT=""
fi

ask_with_default "Type de base de données" "$DEFAULT_DB_TYPE" DB_TYPE

# Ports de base de données par défaut
case $DB_TYPE in
    "postgresql") DB_PORT=5432 ;;
    "mysql") DB_PORT=3306 ;;
    "mongodb") DB_PORT=27017 ;;
    "sqlite") DB_PORT="" ;;
    *) DB_PORT=5432 ;;
esac

if [ -n "$DB_PORT" ]; then
    ask_with_default "Port base de données" "$DB_PORT" DB_PORT
fi

ask_with_default "Utilisateur base de données" "$PROJECT_USER" DB_USER

echo ""
echo "📂 Création de la structure du projet"
echo "====================================="

# Créer les dossiers nécessaires
mkdir -p "$PROJECT_PATH/config"
mkdir -p "$PROJECT_PATH/docs/protocols"
mkdir -p "$PROJECT_PATH/docs/transitions/archives"
mkdir -p "$PROJECT_PATH/utility_scripts"

echo "✅ Dossiers créés"

# Copier le template et le personnaliser
echo "⚙️ Génération de la configuration..."

# Lire le template
TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")

# Remplacer les valeurs
CONFIG_CONTENT=$(echo "$TEMPLATE_CONTENT" | \
    sed "s|\"example_project\"|\"$PROJECT_NAME\"|g" | \
    sed "s|\"username\"|\"$PROJECT_USER\"|g" | \
    sed "s|\"/path/to/your/project/\"|\"$PROJECT_ROOT_PATH\"|g" | \
    sed "s|\"8000\"|$BACKEND_PORT|g" | \
    sed "s|\"postgresql\"|\"$DB_TYPE\"|g" | \
    sed "s|\"5432\"|$DB_PORT|g")

# Gérer le frontend pour les projets backend-only
if [ "$PROJECT_TYPE" = "node_express" ] || [ -z "$FRONTEND_PORT" ]; then
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | \
        sed 's|"port": 3000,|"port": null,|g' | \
        sed 's|"health_endpoint": "/",|"health_endpoint": null,|g' | \
        sed 's|"start_command": ".*"|"start_command": null|g')
else
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s|\"3000\"|$FRONTEND_PORT|g")
fi

# Écrire la configuration
echo "$CONFIG_CONTENT" > "$PROJECT_PATH/config/project_config.json"

echo "✅ Configuration générée: config/project_config.json"

# Copier le fichier d'instructions machine
cp "$FRAMEWORK_PATH/docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md" \
   "$PROJECT_PATH/docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md"

echo "✅ Instructions machine copiées"

# Créer le script de monitoring s'il n'existe pas
MONITOR_SCRIPT="$HOME/scripts/claude_monitor.sh"
if [ ! -f "$MONITOR_SCRIPT" ]; then
    if confirm "Créer le script de monitoring dans ~/scripts/claude_monitor.sh ?"; then
        mkdir -p "$HOME/scripts"
        
        cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash

# Script de monitoring pour Claude
# Calcule le pourcentage d'utilisation approximatif

MESSAGE_COUNT=${1:-1}
MAX_MESSAGES=50  # Ajustez selon vos besoins

PERCENTAGE=$((MESSAGE_COUNT * 100 / MAX_MESSAGES))

if [ $PERCENTAGE -lt 60 ]; then
    echo "✅ OK - Messages: $MESSAGE_COUNT/$MAX_MESSAGES ($PERCENTAGE%)"
elif [ $PERCENTAGE -lt 80 ]; then
    echo "📊 Surveillance active - Messages: $MESSAGE_COUNT/$MAX_MESSAGES ($PERCENTAGE%)"
elif [ $PERCENTAGE -lt 90 ]; then
    echo "⚠️ Attention - Messages: $MESSAGE_COUNT/$MAX_MESSAGES ($PERCENTAGE%)"
else
    echo "🚨 DANGER - Messages: $MESSAGE_COUNT/$MAX_MESSAGES ($PERCENTAGE%)"
fi
EOF
        
        chmod +x "$MONITOR_SCRIPT"
        echo "✅ Script de monitoring créé et rendu exécutable"
    fi
else
    echo "ℹ️ Script de monitoring déjà existant"
fi

# Créer un exemple de CLAUDE.md s'il n'existe pas
if [ ! -f "$PROJECT_PATH/CLAUDE.md" ]; then
    if confirm "Créer un fichier CLAUDE.md d'exemple ?"; then
        cat > "$PROJECT_PATH/CLAUDE.md" << EOF
# CLAUDE.md - Guide d'Intelligence Collaborative pour $PROJECT_NAME

Ce fichier guide les assistants Claude travaillant sur $PROJECT_NAME.

## 🚨 ATTENTION - PIPELINE AUTOMATIQUE

**IMPORTANT** : Ce document doit être lu **ENTIÈREMENT** avant toute action.

Le pipeline automatique sera activé **À LA FIN** de ce document.

## 🎯 Vision du Projet $PROJECT_NAME

[Décrivez ici votre projet...]

## 🏗️ Architecture & Standards

### Stack Technique

- **Type de projet** : $PROJECT_TYPE
- **Backend** : Port $BACKEND_PORT
EOF

        if [ -n "$FRONTEND_PORT" ]; then
            echo "- **Frontend** : Port $FRONTEND_PORT" >> "$PROJECT_PATH/CLAUDE.md"
        fi

        cat >> "$PROJECT_PATH/CLAUDE.md" << EOF
- **Base de données** : $DB_TYPE (Port $DB_PORT)

[Ajoutez ici vos conventions et standards...]

---

## 🚨 DÉMARRAGE OBLIGATOIRE - PIPELINE AUTOMATIQUE

**Vous avez terminé la lecture de CLAUDE.md.**

**MAINTENANT**, chaque Claude DOIT :

1. **LIRE IMMÉDIATEMENT** : \`docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md\`
2. **EXÉCUTER** : \`session_start()\` selon protocole
3. **SUIVRE** : Le pipeline de surveillance automatique

**Cette étape est OBLIGATOIRE et NON-NÉGOCIABLE.**
EOF

        echo "✅ Fichier CLAUDE.md d'exemple créé"
    fi
fi

echo ""
echo "🎉 Configuration terminée !"
echo "=========================="
echo ""
echo "📁 Fichiers créés :"
echo "  - config/project_config.json"
echo "  - docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md"
echo "  - docs/transitions/ (dossier)"
if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
    echo "  - CLAUDE.md"
fi
echo ""
echo "🧪 Tests de validation :"
echo "  1. Vérifier la configuration : cat config/project_config.json | jq '.'"
echo "  2. Tester le monitoring : ~/scripts/claude_monitor.sh 1"
if [ -n "$BACKEND_PORT" ]; then
    echo "  3. Tester le backend : curl http://localhost:$BACKEND_PORT/health"
fi
echo ""
echo "📚 Prochaines étapes :"
echo "  1. Démarrez vos services (backend, frontend, DB)"
echo "  2. Personnalisez CLAUDE.md selon votre projet"
echo "  3. Testez le framework avec un assistant Claude"
echo ""
echo "✨ Le framework Claude est maintenant configuré pour votre projet !"