# 📚 Guide d'Installation - Framework Claude Agnostique

## 🎯 Vue d'ensemble

Ce framework permet d'appliquer les protocoles automatiques Claude à n'importe quel projet de développement. Il remplace les références hardcodées par un système de configuration centralisée.

## 🚀 Installation Rapide

### 1. Copier le Framework

```bash
# Cloner ou copier le framework dans votre projet
cp -r /chemin/vers/framework/* /votre/projet/
```

### 2. Configurer votre Projet

```bash
# Aller dans le dossier config
cd config

# Copier un template selon votre stack
cp templates/fastapi_nextjs.json project_config.json
# OU
cp templates/django_react.json project_config.json
# OU
cp templates/node_express.json project_config.json
```

### 3. Personnaliser la Configuration

Éditez `config/project_config.json` avec vos valeurs :

```json
{
  "project": {
    "name": "mon_projet",
    "root_path": "/chemin/vers/mon/projet/",
    "user": "mon_username",
    "type": "web_app"
  },
  "services": {
    "backend": {
      "port": 8000,
      "health_endpoint": "/health",
      "start_command": "cd backend && python manage.py runserver 8000"
    },
    // ... etc
  }
}
```

## ⚙️ Configuration Détaillée

### Structure du Fichier de Configuration

```json
{
  "project": {
    "name": "{{NOM_DE_VOTRE_PROJET}}",
    "root_path": "{{CHEMIN_ABSOLU_VERS_RACINE_PROJET}}",
    "user": "{{VOTRE_USERNAME}}",
    "type": "{{TYPE_DE_PROJET}}"
  },
  "services": {
    "backend": {
      "port": {{PORT_BACKEND}},
      "health_endpoint": "{{ENDPOINT_HEALTH_CHECK}}",
      "start_command": "{{COMMANDE_DEMARRAGE_BACKEND}}"
    },
    "frontend": {
      "port": {{PORT_FRONTEND_OU_NULL}},
      "health_endpoint": "{{ENDPOINT_FRONTEND_OU_NULL}}",
      "start_command": "{{COMMANDE_DEMARRAGE_FRONTEND_OU_NULL}}"
    },
    "database": {
      "type": "{{postgresql|mysql|mongodb|sqlite}}",
      "version": "{{VERSION_DB}}",
      "port": {{PORT_DB}},
      "host": "{{HOST_DB}}",
      "user": "{{USER_DB}}",
      "extensions": [{{LISTE_EXTENSIONS}}]
    }
  },
  "monitoring": {
    "script_path": "{{CHEMIN_SCRIPT_MONITORING}}",
    "thresholds": {
      "ok": 60,
      "attention": 80,
      "danger": 90
    }
  },
  "structure": {
    "docs_path": "{{DOSSIER_DOCS}}",
    "transitions_path": "{{DOSSIER_TRANSITIONS}}",
    "archives_path": "{{DOSSIER_ARCHIVES}}",
    "protocols_path": "{{DOSSIER_PROTOCOLS}}",
    "backend_path": "{{DOSSIER_BACKEND}}",
    "frontend_path": "{{DOSSIER_FRONTEND}}"
  },
  "critical_files": {
    "start_script": "{{SCRIPT_DEMARRAGE}}",
    "claude_instructions": "{{FICHIER_CLAUDE_MD}}",
    "machine_instructions": "{{FICHIER_INSTRUCTIONS_MACHINE}}"
  },
  "git": {
    "main_branch": "{{BRANCHE_PRINCIPALE}}",
    "remote": "{{NOM_REMOTE}}"
  }
}
```

### Paramètres par Type de Projet

#### FastAPI + Next.js
```json
{
  "project": { "type": "web_app" },
  "services": {
    "backend": {
      "port": 8000,
      "health_endpoint": "/health",
      "start_command": "cd backend && poetry run uvicorn app.main:app --reload --port 8000"
    },
    "frontend": {
      "port": 3000,
      "health_endpoint": "/",
      "start_command": "cd frontend && npm run dev"
    },
    "database": { "type": "postgresql" }
  }
}
```

#### Django + React
```json
{
  "project": { "type": "web_app" },
  "services": {
    "backend": {
      "port": 8000,
      "health_endpoint": "/health/",
      "start_command": "cd backend && python manage.py runserver 8000"
    },
    "frontend": {
      "port": 3000,
      "health_endpoint": "/",
      "start_command": "cd frontend && npm start"
    },
    "database": { "type": "postgresql" }
  }
}
```

#### Node.js Express (API seulement)
```json
{
  "project": { "type": "backend_api" },
  "services": {
    "backend": {
      "port": 3000,
      "health_endpoint": "/health",
      "start_command": "npm run dev"
    },
    "frontend": {
      "port": null,
      "health_endpoint": null,
      "start_command": null
    },
    "database": { "type": "mongodb" }
  }
}
```

## 🛠️ Configuration du Script de Monitoring

### 1. Créer le Script de Monitoring

```bash
# Créer le dossier scripts
mkdir -p ~/scripts

# Créer le script de monitoring
cat > ~/scripts/claude_monitor.sh << 'EOF'
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

# Rendre exécutable
chmod +x ~/scripts/claude_monitor.sh
```

### 2. Tester le Script

```bash
# Test du script
~/scripts/claude_monitor.sh 1   # Devrait afficher "✅ OK"
~/scripts/claude_monitor.sh 35  # Devrait afficher "⚠️ Attention"
~/scripts/claude_monitor.sh 45  # Devrait afficher "🚨 DANGER"
```

## 📁 Structure de Dossiers Requise

Créez la structure de dossiers nécessaire :

```bash
# Dossiers obligatoires
mkdir -p docs/protocols
mkdir -p docs/transitions/archives

# Copier les fichiers du framework
cp docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md
```

## 🔧 Adaptation du Fichier CLAUDE.md

Modifiez votre fichier `CLAUDE.md` pour inclure la référence au framework :

```markdown
# CLAUDE.md - Guide d'Intelligence Collaborative pour [VOTRE_PROJET]

## 🚨 ATTENTION - PIPELINE AUTOMATIQUE

**IMPORTANT** : Ce document doit être lu **ENTIÈREMENT** avant toute action.

Le pipeline automatique sera activé **À LA FIN** de ce document.

[... votre contenu spécifique ...]

---

## 🚨 DÉMARRAGE OBLIGATOIRE - PIPELINE AUTOMATIQUE

**Vous avez terminé la lecture de CLAUDE.md.**

**MAINTENANT**, chaque Claude DOIT :

1. **LIRE IMMÉDIATEMENT** : `docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md`
2. **EXÉCUTER** : `session_start()` selon protocole
3. **SUIVRE** : Le pipeline de surveillance automatique

**Cette étape est OBLIGATOIRE et NON-NÉGOCIABLE.**
```

## ✅ Validation de l'Installation

### 1. Tester la Configuration

```bash
# Vérifier que la configuration est valide
cd /votre/projet
cat config/project_config.json | jq '.'  # Doit être du JSON valide
```

### 2. Tester les Services

```bash
# Vérifier que les ports sont configurés correctement
curl http://localhost:$(jq -r '.services.backend.port' config/project_config.json)/$(jq -r '.services.backend.health_endpoint' config/project_config.json)
```

### 3. Tester le Monitoring

```bash
# Vérifier que le script de monitoring fonctionne
$(jq -r '.monitoring.script_path' config/project_config.json) 1
```

## 🔄 Migration d'un Projet Existant

Si vous avez déjà un projet avec l'ancienne version hardcodée :

### 1. Sauvegarde

```bash
# Sauvegarder les anciens fichiers
cp docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_OLD.md
```

### 2. Créer la Configuration

```bash
# Extraire la configuration de l'ancien fichier
grep -E "(project_root|backend.*port|frontend.*port)" docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_OLD.md
# Utiliser ces valeurs pour remplir config/project_config.json
```

### 3. Remplacer le Fichier

```bash
# Remplacer par la version générique
cp docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md
```

## 🐛 Dépannage

### Problèmes Courants

1. **Configuration non trouvée**
   ```
   ERROR: config/project_config.json not found
   ```
   Solution : Vérifiez que le fichier existe et est au bon endroit

2. **Script de monitoring non exécutable**
   ```
   ERROR: Script monitoring manquant ou non exécutable
   ```
   Solution : `chmod +x ~/scripts/claude_monitor.sh`

3. **Services non accessibles**
   ```
   WARNING: Backend ❌
   ```
   Solution : Vérifiez que les services sont démarrés et les ports corrects

### Debug de la Configuration

```bash
# Afficher la configuration actuelle
cat config/project_config.json | jq '.'

# Vérifier les chemins
ls -la $(jq -r '.project.root_path' config/project_config.json)

# Tester les connexions
curl $(jq -r '"http://localhost:" + (.services.backend.port|tostring) + .services.backend.health_endpoint' config/project_config.json)
```

## 📞 Support

En cas de problème :

1. Vérifiez que tous les fichiers requis sont présents
2. Validez votre configuration JSON
3. Testez manuellement chaque service
4. Vérifiez les permissions des scripts

Le framework est maintenant project-agnostic et peut s'adapter à n'importe quel type de projet en modifiant simplement le fichier de configuration !