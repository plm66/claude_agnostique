# 🤖 Routine Claude Agnostique - Guide d'Adaptation

## 📋 Vue d'ensemble
Cette copie contient le système pipeline automatique complet, rendu agnostique pour adaptation à n'importe quel projet.

## 📁 Structure copiée
```
Projet_50_routineClaude_agnostique/
├── CLAUDE.md                                          # Point d'entrée pipeline
├── docs/
│   ├── protocols/
│   │   └── INSTRUCTIONS_MACHINE_AUTOMATIQUES.md      # Protocole central (1017 lignes)
│   └── transitions/
│       └── archives/                                  # Dossier archives transitions
├── scripts/
│   └── claude_monitor.sh                             # Script surveillance tokens
├── TRANSITION_NOTES_*.md                             # Exemples transitions
└── README_ADAPTATION.md                              # Ce guide
```

## 🔧 Adaptation à un nouveau projet

### 1. **Modifier CLAUDE.md**
- Changer la vision du projet (ligne 21-27)
- Adapter le stack technique (ligne 74-80) 
- Mettre à jour le contexte d'exécution (ligne 164-170)
- Modifier les chemins dans la documentation structure (ligne 175-190)

### 2. **Adapter INSTRUCTIONS_MACHINE_AUTOMATIQUES.md**
- **CRITIQUE** : Changer `project_root = READ_CONFIG("PROJECT_ROOT")` (utilise le fichier .config)
- Adapter les chemins dans les fonctions de validation contexte
- Modifier les ports des services si différents (8001, 3502, 5432)
- Ajuster les fichiers critiques à vérifier

### 3. **Configurer claude_monitor.sh**
- Le script est agnostique, pas de modification requise
- Optionnel : Ajuster TOKENS_PAR_MESSAGE selon complexité projet

### 4. **Déployer dans le nouveau projet**
```bash
# Copier les fichiers
cp CLAUDE.md /chemin/vers/nouveau/projet/
cp -r docs/ /chemin/vers/nouveau/projet/
cp scripts/claude_monitor.sh ~/scripts/  # Ou autre chemin

# Adapter les chemins dans IMA.md
# Modifier project_root et script_path
```

### 5. **Première utilisation**
1. Claude lit CLAUDE.md du nouveau projet
2. Pipeline se lance automatiquement 
3. Validation contexte s'adapte au nouveau projet
4. Monitoring et transitions fonctionnent immédiatement

## ⚙️ Personnalisations avancées

### Variables principales à adapter dans IMA.md :
```python
# Ligne 169 - Chemin projet
project_root = "/chemin/vers/votre/projet/"

# Ligne 174 - Script monitoring  
script_path = "~/scripts/claude_monitor.sh"

# Lignes 904-906 - Services à surveiller
backend_status = TEST_URL("http://localhost:VOTRE_PORT")
frontend_status = TEST_URL("http://localhost:VOTRE_PORT")
postgres_status = TEST_CONNECTION("localhost:VOTRE_PORT")

# Lignes 939-943 - Fichiers critiques
critical_files = [
    project_root + "VOTRE_FICHIER_PRINCIPAL",
    project_root + "docs/protocols/INSTRUCTIONS_MACHINE_AUTOMATIQUES.md",
    script_path
]
```

### Triggers spécialisés (optionnel) :
- Ajouter des checkpoints spécifiques au projet
- Modifier les seuils d'archivage
- Personnaliser les messages de validation

## 🎯 Avantages du système
- **Continuité parfaite** entre sessions Claude
- **Surveillance automatique** des tokens
- **Validation contexte** robuste au démarrage
- **Transitions automatiques** avec sauvegarde
- **Diagnostic automatique** des problèmes

## 📊 Compatibilité
- ✅ Tout projet avec git
- ✅ Tout environnement macOS/Linux  
- ✅ Adaptable Windows (ajuster chemins)
- ✅ Projets mono/multi-langages
- ✅ Avec ou sans services backend

---
*Routine Claude v1.1 - Système pipeline universel*
*Framework Claude Agnostique - 21 juin 2025*
EOF < /dev/null