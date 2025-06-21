# 🤖 Framework Claude Agnostique

Un framework de routines automatiques Claude générique et configurable pour n'importe quel projet de développement.

## 🎯 Vue d'ensemble

Ce framework transforme les protocoles Claude spécifiques en un système générique réutilisable. Il remplace toutes les références hardcodées par un système de configuration centralisée, permettant son utilisation sur n'importe quel type de projet.

### ✨ Fonctionnalités

- **🔧 Configuration centralisée** : Un seul fichier JSON pour tout configurer
- **🚀 Installation automatique** : Scripts d'installation et de validation
- **📊 Monitoring intelligent** : Surveillance automatique des tokens de conversation
- **🔄 Transitions automatiques** : Sauvegarde automatique du contexte
- **📚 Templates prêts à l'emploi** : Configurations pour FastAPI, Django, Node.js, etc.
- **✅ Validation complète** : Vérification automatique de l'installation

## 🚀 Installation Rapide

### 1. Cloner le Framework

```bash
git clone [ce-repo] /chemin/vers/framework-claude
cd /votre/projet
```

### 2. Configuration Automatique

```bash
# Pour un projet FastAPI + Next.js
/chemin/vers/framework-claude/utility_scripts/setup/configure_project.sh fastapi_nextjs /votre/projet

# Pour un projet Django + React
/chemin/vers/framework-claude/utility_scripts/setup/configure_project.sh django_react /votre/projet

# Pour un projet Node.js Express
/chemin/vers/framework-claude/utility_scripts/setup/configure_project.sh node_express /votre/projet
```

### 3. Validation

```bash
cd /votre/projet
/chemin/vers/framework-claude/utility_scripts/setup/validate_installation.sh
```

## 📋 Types de Projets Supportés

| Template | Description | Backend | Frontend | Database |
|----------|-------------|---------|----------|----------|
| `fastapi_nextjs` | API Python moderne + React | FastAPI (Poetry) | Next.js | PostgreSQL |
| `django_react` | Framework Python classique | Django | React | PostgreSQL |
| `node_express` | API JavaScript/TypeScript | Express.js | - | MongoDB |

## ⚙️ Structure de Configuration

```json
{
  "project": {
    "name": "mon_projet",
    "root_path": "/chemin/vers/projet/",
    "user": "username",
    "type": "web_app"
  },
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
    "database": {
      "type": "postgresql",
      "version": "15.x",
      "port": 5432,
      "host": "localhost",
      "user": "username",
      "extensions": ["pgvector:0.8.0"]
    }
  },
  "monitoring": {
    "script_path": "~/scripts/claude_monitor.sh",
    "thresholds": { "ok": 60, "attention": 80, "danger": 90 }
  }
}
```

## 🔧 Installation Manuelle

### 1. Copier les Fichiers

```bash
# Structure minimale requise
mkdir -p config docs/protocols docs/transitions/archives utility_scripts

# Fichiers essentiels
cp framework/config/project_config_template.json config/project_config.json
cp framework/docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md
```

### 2. Configurer le Projet

Éditez `config/project_config.json` avec vos valeurs :

```bash
# Utiliser un template existant
cp framework/config/templates/fastapi_nextjs.json config/project_config.json

# Personnaliser les valeurs
nano config/project_config.json
```

### 3. Script de Monitoring

```bash
# Créer le script de monitoring
mkdir -p ~/scripts
cat > ~/scripts/claude_monitor.sh << 'EOF'
#!/bin/bash
MESSAGE_COUNT=${1:-1}
MAX_MESSAGES=50
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

chmod +x ~/scripts/claude_monitor.sh
```

## 📚 Documentation

### Guides Détaillés

- **[📖 Guide d'Installation](INSTALLATION_GUIDE.md)** : Installation complète pas à pas
- **[⚙️ Configuration Avancée](config/README.md)** : Personnalisation poussée
- **[🔧 Scripts Utilitaires](utility_scripts/README.md)** : Automatisation et maintenance

### Fichiers Techniques

- **[🤖 Instructions Machine](docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md)** : Protocoles Claude
- **[📋 Templates](config/templates/)** : Configurations prêtes à l'emploi

## 🧪 Tests et Validation

### Validation Automatique

```bash
# Test complet de l'installation
./utility_scripts/setup/validate_installation.sh

# Test de la configuration seulement
cat config/project_config.json | jq '.'

# Test du monitoring
~/scripts/claude_monitor.sh 1
```

### Tests Manuels

```bash
# Vérifier les services
curl http://localhost:8000/health  # Backend
curl http://localhost:3000/        # Frontend

# Vérifier la base de données
nc -z localhost 5432               # PostgreSQL
nc -z localhost 27017              # MongoDB
```

## 🔄 Utilisation avec Claude

### 1. Démarrage d'une Session

1. L'assistant Claude lit automatiquement `CLAUDE.md`
2. Puis charge `docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md`
3. Exécute `session_start()` qui :
   - Charge la configuration depuis `config/project_config.json`
   - Navigue vers le répertoire projet
   - Lit le dernier document de transition
   - Lance le monitoring automatique

### 2. Surveillance Automatique

- **Toutes les 5 interactions** : Vérification automatique des tokens
- **Seuils configurables** : 60% surveillance, 80% attention, 90% danger
- **Transitions automatiques** : Sauvegarde du contexte avant dépassement

### 3. Fin de Session

- Trigger `cloture` détecte la fin souhaitée
- Génération automatique du document de transition
- Commit automatique avec TODO list
- Archivage des anciens documents

## 🛠️ Personnalisation

### Ajouter un Nouveau Type de Projet

1. **Créer un template** :
```bash
cp config/templates/fastapi_nextjs.json config/templates/mon_template.json
```

2. **Modifier les valeurs** dans le nouveau template

3. **Utiliser le template** :
```bash
./utility_scripts/setup/configure_project.sh mon_template /mon/projet
```

### Modifier les Seuils de Monitoring

```json
{
  "monitoring": {
    "thresholds": {
      "ok": 70,        # Était 60
      "attention": 85, # Était 80  
      "danger": 95     # Était 90
    }
  }
}
```

### Ajouter des Services Personnalisés

```json
{
  "services": {
    "redis": {
      "port": 6379,
      "health_endpoint": null,
      "start_command": "redis-server"
    },
    "elasticsearch": {
      "port": 9200,
      "health_endpoint": "/_cluster/health",
      "start_command": "elasticsearch"
    }
  }
}
```

## 🔧 Maintenance

### Mise à jour du Framework

```bash
# Sauvegarder la configuration actuelle
cp config/project_config.json config/project_config.json.backup

# Mettre à jour les fichiers du framework
cp framework/docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md

# Vérifier la compatibilité
./utility_scripts/setup/validate_installation.sh
```

### Nettoyage des Transitions

```bash
# Les transitions sont automatiquement archivées
# Dossier : docs/transitions/archives/YYYY/MM/

# Nettoyage manuel si nécessaire
find docs/transitions/archives/ -name "*.md" -mtime +90 -delete
```

### Debug de Configuration

```bash
# Afficher la configuration
cat config/project_config.json | jq '.'

# Tester les connexions
jq -r '"http://localhost:" + (.services.backend.port|tostring) + .services.backend.health_endpoint' config/project_config.json | xargs curl

# Vérifier les chemins
jq -r '.project.root_path' config/project_config.json | xargs ls -la
```

## 🆘 Dépannage

### Problèmes Courants

| Problème | Solution |
|----------|----------|
| Configuration non trouvée | Vérifier `config/project_config.json` existe |
| Script monitoring non exécutable | `chmod +x ~/scripts/claude_monitor.sh` |
| Services non accessibles | Vérifier ports et démarrage services |
| JSON invalide | Valider avec `jq '.' config/project_config.json` |

### Logs et Debug

```bash
# Vérifier la syntaxe JSON
jq empty config/project_config.json && echo "JSON valide" || echo "JSON invalide"

# Test complet avec debug
./utility_scripts/setup/validate_installation.sh 2>&1 | tee validation.log

# Vérifier les permissions
ls -la ~/scripts/claude_monitor.sh
```

## 🤝 Contribution

### Structure du Projet

```
framework-claude/
├── config/
│   ├── project_config.json         # Config exemple actuelle
│   ├── project_config_template.json # Template vierge
│   └── templates/                   # Templates par type
├── docs/
│   └── protocols/
│       └── INSTRUCTIONS_MACHINE_AUTOMATIQUES_GENERIC.md
├── utility_scripts/
│   └── setup/
│       ├── configure_project.sh     # Configuration automatique
│       └── validate_installation.sh # Validation
├── INSTALLATION_GUIDE.md            # Guide détaillé
└── README.md                        # Ce fichier
```

### Ajouter un Template

1. Créer le fichier dans `config/templates/`
2. Ajouter la logique dans `configure_project.sh`
3. Documenter dans ce README
4. Tester avec `validate_installation.sh`

## 📄 Licence

Ce framework est distribué sous licence MIT. Libre d'utilisation, modification et redistribution.

## 🎉 Remerciements

Framework développé pour optimiser les interactions avec les assistants Claude et maintenir la continuité des projets de développement complexes.

---

**Version** : 2.0 Générique  
**Compatibilité** : Tous types de projets  
**Status** : Production Ready  
**Dernière mise à jour** : 21 juin 2025