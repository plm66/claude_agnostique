#!/bin/bash

# Script de validation de l'installation du framework Claude
# Usage: ./validate_installation.sh [project_path]

set -e

# Configuration
PROJECT_PATH=${1:-$(pwd)}
ERRORS=0
WARNINGS=0

# Couleurs pour l'affichage
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
error() {
    echo -e "${RED}❌ ERREUR: $1${NC}"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  ATTENTION: $1${NC}"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Fonction pour vérifier si un fichier existe
check_file() {
    local file="$1"
    local description="$2"
    local required="$3"
    
    if [ -f "$file" ]; then
        success "$description: $file"
        return 0
    else
        if [ "$required" = "true" ]; then
            error "$description manquant: $file"
        else
            warning "$description manquant (optionnel): $file"
        fi
        return 1
    fi
}

# Fonction pour vérifier si un dossier existe
check_directory() {
    local dir="$1"
    local description="$2"
    local required="$3"
    
    if [ -d "$dir" ]; then
        success "$description: $dir"
        return 0
    else
        if [ "$required" = "true" ]; then
            error "$description manquant: $dir"
        else
            warning "$description manquant (optionnel): $dir"
        fi
        return 1
    fi
}

# Fonction pour valider le JSON
validate_json() {
    local file="$1"
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$file" >/dev/null 2>&1; then
            success "Configuration JSON valide: $file"
            return 0
        else
            error "Configuration JSON invalide: $file"
            return 1
        fi
    else
        warning "jq non installé - impossible de valider le JSON"
        return 0
    fi
}

# Fonction pour tester la connectivité vers un service
test_service() {
    local host="$1"
    local port="$2"
    local name="$3"
    
    if command -v nc >/dev/null 2>&1; then
        if nc -z "$host" "$port" 2>/dev/null; then
            success "Service $name accessible sur $host:$port"
            return 0
        else
            warning "Service $name non accessible sur $host:$port"
            return 1
        fi
    elif command -v telnet >/dev/null 2>&1; then
        if timeout 2 telnet "$host" "$port" >/dev/null 2>&1; then
            success "Service $name accessible sur $host:$port"
            return 0
        else
            warning "Service $name non accessible sur $host:$port"
            return 1
        fi
    else
        info "Outils de test réseau (nc/telnet) non disponibles"
        return 0
    fi
}

# Fonction pour tester une URL HTTP
test_http() {
    local url="$1"
    local name="$2"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s --connect-timeout 5 "$url" >/dev/null 2>&1; then
            success "Endpoint $name accessible: $url"
            return 0
        else
            warning "Endpoint $name non accessible: $url"
            return 1
        fi
    else
        info "curl non disponible - impossible de tester $url"
        return 0
    fi
}

echo "🔍 Validation de l'Installation du Framework Claude"
echo "=================================================="
echo "Répertoire du projet: $PROJECT_PATH"
echo ""

# Vérifier que nous sommes dans un projet
if [ ! -d "$PROJECT_PATH" ]; then
    error "Répertoire projet non trouvé: $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

echo "📁 Vérification de la structure des dossiers"
echo "============================================="

# Vérifier les dossiers obligatoires
check_directory "config" "Dossier configuration" true
check_directory "docs" "Dossier documentation" true
check_directory "docs/protocols" "Dossier protocoles" true
check_directory "docs/transitions" "Dossier transitions" true
check_directory "docs/transitions/archives" "Dossier archives" false

echo ""
echo "📄 Vérification des fichiers de configuration"
echo "=============================================="

# Vérifier les fichiers obligatoires
check_file "config/project_config.json" "Configuration projet" true
check_file "docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md" "Instructions machine" true
check_file "CLAUDE.md" "Instructions Claude" false

echo ""
echo "🔧 Validation de la configuration JSON"
echo "======================================"

if [ -f "config/project_config.json" ]; then
    validate_json "config/project_config.json"
    
    # Lire la configuration si jq est disponible
    if command -v jq >/dev/null 2>&1; then
        PROJECT_NAME=$(jq -r '.project.name // "unknown"' config/project_config.json)
        PROJECT_ROOT=$(jq -r '.project.root_path // "unknown"' config/project_config.json)
        BACKEND_PORT=$(jq -r '.services.backend.port // "unknown"' config/project_config.json)
        FRONTEND_PORT=$(jq -r '.services.frontend.port // "null"' config/project_config.json)
        DB_PORT=$(jq -r '.services.database.port // "unknown"' config/project_config.json)
        MONITOR_SCRIPT=$(jq -r '.monitoring.script_path // "unknown"' config/project_config.json)
        
        success "Projet: $PROJECT_NAME"
        success "Racine: $PROJECT_ROOT"
        success "Backend: port $BACKEND_PORT"
        if [ "$FRONTEND_PORT" != "null" ]; then
            success "Frontend: port $FRONTEND_PORT"
        else
            info "Frontend: non configuré (normal pour API backend)"
        fi
        success "Base de données: port $DB_PORT"
    fi
fi

echo ""
echo "🖥️ Vérification du script de monitoring"
echo "======================================="

if [ -f "config/project_config.json" ] && command -v jq >/dev/null 2>&1; then
    MONITOR_SCRIPT=$(jq -r '.monitoring.script_path // "~/scripts/claude_monitor.sh"' config/project_config.json)
    
    # Expansion du tilde
    MONITOR_SCRIPT_EXPANDED="${MONITOR_SCRIPT/#\~/$HOME}"
    
    if [ -f "$MONITOR_SCRIPT_EXPANDED" ]; then
        success "Script monitoring trouvé: $MONITOR_SCRIPT_EXPANDED"
        
        if [ -x "$MONITOR_SCRIPT_EXPANDED" ]; then
            success "Script monitoring exécutable"
            
            # Tester l'exécution du script
            if OUTPUT=$("$MONITOR_SCRIPT_EXPANDED" 1 2>&1); then
                success "Script monitoring fonctionne: $OUTPUT"
            else
                error "Script monitoring échoue: $OUTPUT"
            fi
        else
            error "Script monitoring non exécutable: $MONITOR_SCRIPT_EXPANDED"
        fi
    else
        error "Script monitoring non trouvé: $MONITOR_SCRIPT_EXPANDED"
    fi
else
    warning "Impossible de vérifier le script monitoring (config manquante ou jq absent)"
fi

echo ""
echo "🌐 Test de connectivité des services"
echo "===================================="

if [ -f "config/project_config.json" ] && command -v jq >/dev/null 2>&1; then
    # Tester le backend
    BACKEND_PORT=$(jq -r '.services.backend.port // "8000"' config/project_config.json)
    BACKEND_HEALTH=$(jq -r '.services.backend.health_endpoint // "/health"' config/project_config.json)
    test_service "localhost" "$BACKEND_PORT" "Backend"
    test_http "http://localhost:$BACKEND_PORT$BACKEND_HEALTH" "Backend Health"
    
    # Tester le frontend s'il existe
    FRONTEND_PORT=$(jq -r '.services.frontend.port // "null"' config/project_config.json)
    if [ "$FRONTEND_PORT" != "null" ]; then
        FRONTEND_HEALTH=$(jq -r '.services.frontend.health_endpoint // "/"' config/project_config.json)
        test_service "localhost" "$FRONTEND_PORT" "Frontend"
        test_http "http://localhost:$FRONTEND_PORT$FRONTEND_HEALTH" "Frontend"
    fi
    
    # Tester la base de données
    DB_PORT=$(jq -r '.services.database.port // "5432"' config/project_config.json)
    DB_TYPE=$(jq -r '.services.database.type // "postgresql"' config/project_config.json)
    if [ "$DB_PORT" != "null" ] && [ "$DB_PORT" != "" ]; then
        test_service "localhost" "$DB_PORT" "Base de données ($DB_TYPE)"
    fi
else
    info "Tests de connectivité ignorés (config manquante ou jq absent)"
fi

echo ""
echo "🐙 Vérification Git"
echo "==================="

if git rev-parse --git-dir >/dev/null 2>&1; then
    success "Repository Git détecté"
    
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    success "Branche actuelle: $CURRENT_BRANCH"
    
    if git status --porcelain | grep -q .; then
        info "Modifications non commitées détectées (normal)"
    else
        success "Repository Git propre"
    fi
else
    warning "Pas de repository Git trouvé"
fi

echo ""
echo "📊 Résumé de la validation"
echo "=========================="

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 Installation parfaite ! Aucun problème détecté.${NC}"
        echo ""
        echo "✨ Le framework Claude est prêt à être utilisé !"
        echo ""
        echo "🚀 Prochaines étapes :"
        echo "  1. Démarrez vos services si ce n'est pas fait"
        echo "  2. Testez avec un assistant Claude"
        echo "  3. Personnalisez CLAUDE.md selon vos besoins"
    else
        echo -e "${YELLOW}⚠️  Installation OK avec $WARNINGS avertissement(s).${NC}"
        echo ""
        echo "Le framework peut fonctionner, mais vérifiez les points ci-dessus."
    fi
    exit 0
else
    echo -e "${RED}❌ Installation incomplète : $ERRORS erreur(s) et $WARNINGS avertissement(s).${NC}"
    echo ""
    echo "Corrigez les erreurs avant d'utiliser le framework."
    exit 1
fi