# 🔍 Standards de Validation Multi-Agents - GÉNÉRIQUE

Ce document définit les standards universels de validation pour tous les assistants Claude travaillant en mode multi-agents, **agnostique du langage et de la technologie**.

## 🎯 Objectif

Garantir la qualité et la stabilité du code lors des développements parallèles en équipe, en évitant les régressions et les erreurs de compilation/exécution dans **tout environnement de développement**.

## ⚠️ Règles Non-Négociables Universelles

### 1. **Aucun signal "READY" sans validation complète**
### 2. **Zero tolerance pour les erreurs de syntaxe/compilation**
### 3. **Test fonctionnel obligatoire dans l'environnement cible**

---

## 📋 Template Bloc d'Instructions Standard Générique

```markdown
MISSION : [Description de la mission]
DURÉE : [X] minutes
PRIORITÉ : [CRITIQUE/MOYENNE/FAIBLE]
DÉPENDANCES : [Si applicable]
TECHNOLOGIE : [Python/Rust/JavaScript/TypeScript/Go/etc.]

ÉTAPES :
1. [Étapes de développement...]

2. [Code du composant/module...]

🔍 VALIDATION OBLIGATOIRE :
3. Vérifier syntaxe/compilation :
   ```bash
   # ADAPTEZ selon votre stack :
   
   # Python
   python -m py_compile [fichier.py]
   # OU
   flake8 [fichier.py]
   # OU
   mypy [fichier.py]
   
   # JavaScript/TypeScript
   npm run type-check
   # OU
   npx tsc --noEmit
   
   # Rust
   cargo check
   # OU
   cargo clippy
   
   # Go
   go build
   # OU
   go vet
   
   # C/C++
   gcc -fsyntax-only [fichier.c]
   # OU
   clang++ -fsyntax-only [fichier.cpp]
   ```
   ⚠️ STOP si erreurs - corriger avant de continuer

4. Tester compilation/build :
   ```bash
   # ADAPTEZ selon votre environnement :
   
   # Python
   python -c "import [module]"
   
   # JavaScript/Node.js
   npm run build
   # OU
   npm run dev
   
   # Rust
   cargo build
   
   # Go
   go build ./...
   
   # C/C++
   make
   # OU
   cmake --build .
   ```

5. Test fonctionnel rapide :
   - Exécuter votre code dans l'environnement cible
   - Vérifier que votre module/composant fonctionne
   - Tester interaction/API basique
   - Vérifier logs/console pour erreurs

6. SIGNAL DE FIN : Écrire "[AGENT]-[COMPOSANT]-READY" dans le chat
   SEULEMENT si toutes les vérifications passent ✅
```

---

## 🚨 Checklist de Validation Universelle

### Phase 1 : Validation Syntaxique
```bash
□ Syntaxe correcte = ✅ NO ERRORS
□ Aucun warning critique du linter
□ Imports/includes corrects
□ Typage/annotations valides (si applicable)
```

### Phase 2 : Validation Compilation/Build
```bash
□ Build/compilation = ✅ SUCCESSFUL
□ Dépendances résolues correctement
□ Aucune erreur de linking/packaging
```

### Phase 3 : Validation Fonctionnelle
```bash
□ Exécution sans crash = ✅ FUNCTIONAL
□ Module/composant s'exécute correctement
□ Interactions de base fonctionnent
□ Aucun effet de bord visible
```

### Phase 4 : Signal Autorisé
```bash
□ TOUTES les phases précédentes = ✅
□ Signal "[AGENT]-[COMPOSANT]-READY" envoyé
```

---

## 🔧 Commandes de Validation par Technologie

### Python
```bash
# Validation syntaxe
python -m py_compile *.py
flake8 .
mypy .

# Test imports
python -c "import your_module"

# Exécution
python main.py
pytest  # si tests unitaires
```

### JavaScript/TypeScript/Node.js
```bash
# Validation TypeScript
npm run type-check
npx tsc --noEmit

# Build
npm run build
npm run dev

# Test
npm test
node index.js
```

### Rust
```bash
# Validation
cargo check
cargo clippy

# Build
cargo build
cargo build --release

# Test
cargo test
cargo run
```

### Go
```bash
# Validation
go vet ./...
golint ./...

# Build
go build ./...
go mod tidy

# Test
go test ./...
go run main.go
```

### Python/Django
```bash
# Validation Django
python manage.py check
python manage.py makemigrations --dry-run

# Test
python manage.py test
python manage.py runserver
```

### C/C++
```bash
# Validation
gcc -fsyntax-only *.c
clang++ -fsyntax-only *.cpp

# Build
make
cmake --build .

# Test
./executable
valgrind ./executable  # si disponible
```

---

## ❌ Résolution d'Erreurs Universelle

### Erreur de Syntaxe
1. **Lire l'erreur complètement** (ligne, colonne, message)
2. **Corriger la syntaxe** selon les règles du langage
3. **Re-tester la validation syntaxique**
4. **Ne pas continuer tant que des erreurs subsistent**

### Erreur de Compilation/Build
1. **Vérifier les dépendances** (imports, includes, libs)
2. **Corriger les erreurs signalées** par le compilateur
3. **Attendre build successful**
4. **Tester l'exécution**

### Erreur d'Exécution
1. **Vérifier les logs/console** d'erreur
2. **Identifier les erreurs runtime**
3. **Corriger le code logique**
4. **Re-tester toute la chaîne**

---

## 📊 Exemples de Validation Réussie

### ✅ Python OK
```bash
$ python -m py_compile module.py
# Aucune sortie = ✅ SUCCESS

$ python -c "import module"
# Aucune erreur = ✅ SUCCESS
```

### ✅ Rust OK
```bash
$ cargo check
   Compiling project v0.1.0
    Finished dev [unoptimized + debuginfo] target(s) in 2.3s
```

### ✅ JavaScript OK
```bash
$ npm run build
✓ Compiled successfully in 1.8s
```

### ✅ Go OK
```bash
$ go build ./...
# Aucune sortie = ✅ SUCCESS

$ go test ./...
ok      module/package    0.123s
```

---

## 🎯 Standards par Type de Développement

### Composants Frontend (React, Vue, Angular, etc.)
- **Visual check** : Rendu correct dans navigateur
- **Interaction check** : Events/hooks fonctionnent
- **Props/data check** : Données passées correctement

### Services Backend (API, microservices, etc.)
- **Endpoint check** : Routes accessibles
- **Database check** : Connexions/requêtes OK
- **Logic check** : Business logic fonctionnelle

### Scripts/CLI Tools
- **Arguments check** : Paramètres traités correctement
- **I/O check** : Lecture/écriture fichiers OK
- **Error handling** : Gestion erreurs appropriée

### Libraries/Modules
- **API check** : Interface publique stable
- **Dependencies** : Dépendances minimales
- **Documentation** : Usage clair et exemples

---

## 📚 Outils Universels Recommandés

### Linters/Formatters
- **Python** : flake8, black, pylint
- **JavaScript** : ESLint, Prettier
- **Rust** : clippy, rustfmt
- **Go** : gofmt, golint, go vet
- **C/C++** : clang-format, cppcheck

### Type Checkers
- **Python** : mypy, pyright
- **JavaScript** : TypeScript
- **Rust** : Built-in type system
- **Go** : Built-in type system

### Testing Frameworks
- **Python** : pytest, unittest
- **JavaScript** : Jest, Mocha, Vitest
- **Rust** : Built-in test framework
- **Go** : Built-in testing package

---

## ⚖️ Responsabilités Universelles

### Chaque Assistant DOIT :
- ✅ Adapter ce protocole à sa technologie
- ✅ Ne jamais signaler READY sans validation complète
- ✅ Corriger TOUTES les erreurs avant de continuer
- ✅ Tester son code dans l'environnement cible

### Le Directeur Claude DOIT :
- ✅ Adapter les standards à la stack du projet
- ✅ Inclure les commandes spécifiques dans chaque bloc
- ✅ Vérifier que les signaux READY sont légitimes
- ✅ Stopper la mission si validation insuffisante

---

## 🔄 Adaptation par Projet

**Avant utilisation dans un nouveau projet :**

1. **Identifier la stack technique** (langages, frameworks, outils)
2. **Adapter les commandes de validation** selon l'environnement
3. **Définir les outils spécifiques** (linters, formatters, etc.)
4. **Tester le protocole** sur un composant simple
5. **Documenter les adaptations** dans le README du projet

---

**Version** : 1.0 GÉNÉRIQUE  
**Dernière mise à jour** : 22 juin 2025  
**Statut** : TEMPLATE UNIVERSEL - À adapter par projet  
**Compatible** : Python, JavaScript, TypeScript, Rust, Go, C/C++, Java, C#, PHP, Ruby, etc.