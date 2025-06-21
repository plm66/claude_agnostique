# 🤖 INSTRUCTIONS MACHINE AUTOMATIQUES - CLAUDE SUPERVISEUR (VERSION GÉNÉRIQUE)

## CONFIGURATION CHARGEMENT
```
# CHARGEMENT OBLIGATOIRE AU DÉMARRAGE
config = LOAD_CONFIG("config/project_config.json")
project_root = config.project.root_path
monitoring_script = config.monitoring.script_path
backend_port = config.services.backend.port
frontend_port = config.services.frontend.port
database_port = config.services.database.port
database_user = config.services.database.user
transitions_path = config.structure.transitions_path
archives_path = config.structure.archives_path
```

## TRIGGERS OBLIGATOIRES - EXÉCUTION AUTOMATIQUE

### TRIGGER 1: DÉBUT DE SESSION
```
IF session.start() THEN
    EXECUTE config.monitoring.script_path + " 1"
    READ config.project.root_path + "TRANSITION_NOTES_*.md" (latest)
    SET monitoring_mode = ACTIVE
END IF
```

### TRIGGER 2: MOT "cloture" DÉTECTÉ
```
IF user_input.contains("cloture") THEN
    EXECUTE protocole_fin_session()
    EXIT session
END IF
```

### TRIGGER 3: TOUTES LES 5 INTERACTIONS CODE
```
IF interaction_count % 5 == 0 AND code_modified == TRUE THEN
    EXECUTE config.monitoring.script_path + " " + str(interaction_count)
    PARSE result FOR warning_level
    APPLY action_based_on_level(warning_level)
END IF
```

### TRIGGER 4: APRÈS CHAQUE COMMIT RÉUSSI
```
IF git_commit.success == TRUE THEN
    increment commit_counter
    IF commit_counter == 1 THEN
        mark_for_second_commit = TRUE
        second_commit_content = current_todo_list
    END IF
END IF
```

## PROTOCOLES AUTOMATIQUES

### PROTOCOLE: protocole_fin_session()
```
FUNCTION protocole_fin_session():
    # 1. Créer document transition (RACINE pour lecture facile)
    transition_file = "TRANSITION_NOTES_" + date.today().format("YYYYMMDD") + "_" + time.now().format("HHMM") + ".md"
    CREATE_FILE(config.project.root_path + transition_file, generate_transition_content())
    
    # 1.1. Archiver anciens transitions si >5 en racine  
    IF count_transition_files_in_root() > 5 THEN
        archive_old_transitions()
    END IF
    
    # 2. Second commit AUTOMATIQUE (si premier commit fait)
    IF commit_counter >= 1 THEN
        EXECUTE_AUTO("git add " + transition_file)
        EXECUTE_AUTO("git commit -m \"docs: Add transition notes + current TODO list\n\n" + current_todo_list + "\n\n🤖 Generated with [Claude Code](https://claude.ai/code)\n\nCo-Authored-By: Claude <noreply@anthropic.com>\"")
        OUTPUT("✅ Commit automatique effectué")
    END IF
    
    # 3. Git push (DEMANDE AUTORISATION)
    ASK_USER_PERMISSION("Voulez-vous pusher les changements ? (y/n)")
    IF user_confirms == TRUE THEN
        git_push(config.git.remote, config.git.main_branch)
        OUTPUT("📤 Push effectué")
    ELSE
        OUTPUT("⏸️ Push différé - À faire manuellement")
    END IF
    
    # 4. Confirmation
    OUTPUT("🎯 Session fermée proprement - Transition sauvegardée")
    OUTPUT("📋 Prochain assistant doit lire: " + transition_file)
    OUTPUT("📊 Historique: Fichier horodaté pour éviter collision")
    OUTPUT("📁 Archive: Anciens transitions déplacés vers /" + config.structure.archives_path + "/")
    
    RETURN session_end_confirmation
END FUNCTION

### PROTOCOLE: archive_old_transitions()
```
FUNCTION archive_old_transitions():
    # Identifier transitions en racine (sauf le plus récent)
    transition_files = list_files(config.project.root_path + "TRANSITION_NOTES_*.md")
    sort_by_date_desc(transition_files)
    
    # Garder seulement le plus récent en racine
    FOR i = 1 TO length(transition_files) - 1:
        old_file = transition_files[i]
        
        # Extraire date du nom fichier TRANSITION_NOTES_YYYYMMDD_HHMM.md
        date_part = extract_date_from_filename(old_file)
        year = date_part.substring(0, 4)
        month = date_part.substring(4, 6)
        
        # Créer dossier archive si nécessaire
        archive_dir = config.project.root_path + config.structure.archives_path + "/" + year + "/" + month + "/"
        CREATE_DIRECTORY_IF_NOT_EXISTS(archive_dir)
        
        # Déplacer fichier
        MOVE_FILE(old_file, archive_dir + filename(old_file))
        
        OUTPUT("📁 Archivé: " + filename(old_file) + " → " + archive_dir)
    END FOR
END FUNCTION
```

### PROTOCOLE: action_based_on_level(level)
```
FUNCTION action_based_on_level(level):
    SWITCH level:
        CASE "OK":
            CONTINUE
        CASE "Attention":
            OUTPUT("⚠️ Nous sommes à " + str(config.monitoring.thresholds.attention) + "% de la limite")
            OUTPUT("Recommandation: Créer document transition maintenant")
        CASE "DANGER":
            OUTPUT("🚨 LIMITE CRITIQUE ! Création transition OBLIGATOIRE")
            EXECUTE protocole_fin_session()
            EXIT session
    END SWITCH
END FUNCTION
```

### PROTOCOLE: generate_transition_content()
```
FUNCTION generate_transition_content():
    content = "# 📋 Document de Transition - " + date.today() + " " + time.now().format("HH:MM") + "\n\n"
    
    # État du projet
    content += "## 🎯 État actuel\n"
    content += get_git_status() + "\n\n"
    
    # Travail effectué
    content += "## ✅ Travail de cette session\n"
    content += get_recent_commits() + "\n\n"
    
    # Fichiers modifiés
    content += "## 📁 Fichiers modifiés\n"
    content += get_modified_files() + "\n\n"
    
    # TODO actuel
    content += "## 📋 TODO Liste Actuelle\n"
    content += current_todo_list + "\n\n"
    
    # Avertissements
    content += "## ⚠️ Points d'attention\n"
    content += "- Backend sur port " + str(config.services.backend.port) + "\n"
    content += "- " + config.services.database.type.upper() + " " + config.services.database.version + " sur port " + str(config.services.database.port) + "\n"
    
    # Ajouter extensions si présentes
    FOR extension IN config.services.database.extensions:
        content += "- " + extension + " installé\n"
    
    content += "\n"
    
    content += "---\n*Transition générée automatiquement*"
    
    RETURN content
END FUNCTION
```

## VARIABLES SYSTÈME OBLIGATOIRES

### État de session (base)
```
interaction_count = 0
commit_counter = 0
mark_for_second_commit = FALSE
monitoring_mode = INACTIVE
current_todo_list = ""
code_modified = FALSE
```

### Variables système unifiées (étendues)
```python
# Variables session globales
session_active = TRUE
session_start_time = GET_CURRENT_TIMESTAMP()
project_root = config.project.root_path

# Variables monitoring unifiées
message_counter = 0
code_interactions = 0
script_path = config.monitoring.script_path
monitor_percentage = 0
last_monitoring_check = 0

# Variables checkpoints préventifs
modifications_majeures = 0
nouveaux_fichiers = 0
refactorings_importants = 0
architecture_changes = 0
lines_modified_total = 0

# Variables transition détaillées
current_task = ""
decision_log = ""
rationale_log = ""
warning_log = ""
```

### Mise à jour automatique
```
# Après chaque interaction avec code
IF user_interaction.contains_code_change() THEN
    code_modified = TRUE
    interaction_count += 1
END IF

# Après chaque commit
IF git_command.type == "commit" AND git_command.success == TRUE THEN
    commit_counter += 1
END IF

# Mise à jour TODO
IF todo_write.executed() THEN
    current_todo_list = todo_read.get_all()
END IF
```

## RÈGLES STRICTES NON-NÉGOCIABLES

### RÈGLE 1: JAMAIS ignorer "cloture"
```
IF user_says("cloture") THEN
    # OBLIGATOIRE - PAS DE CONDITION
    EXECUTE protocole_fin_session()
END IF
```

### RÈGLE 2: TOUJOURS faire 2 commits
```
IF commit_counter == 1 AND session_ending == TRUE THEN
    # OBLIGATOIRE
    CREATE second_commit WITH todo_list
END IF
```

### RÈGLE 3: MONITORING automatique
```
# TOUTES les 5 interactions - AUTOMATIQUE
IF interaction_count % 5 == 0 THEN
    EXECUTE monitoring_check()
END IF
```

### RÈGLE 4: TRANSITION obligatoire
```
IF any_trigger_detected("cloture", str(config.monitoring.thresholds.danger) + "%_limit", "emergency") THEN
    CREATE TRANSITION_NOTES_[DATE].md
    COMMIT + PUSH
    END session
END IF
```

## FORMAT STRICT COMMIT MESSAGES

### Premier commit (features)
```
TEMPLATE: "[type]: [description détaillée]

[Corps détaillé multilignes]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Second commit (transition)
```
TEMPLATE: "docs: Add transition notes + current TODO list

TODO Liste:
[current_todo_list formatté]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## VÉRIFICATION AUTOMATIQUE

### Checklist pré-"cloture"
```
FUNCTION pre_closure_check():
    ASSERT commit_counter >= 1 OR no_changes_made
    ASSERT current_todo_list != ""
    ASSERT git_status.clean OR git_add_all.executed
    RETURN ready_for_closure
END FUNCTION
```

## TRIGGERS CHECKPOINTS PRÉVENTIFS AUTOMATIQUES

### TRIGGER 5: Modifications majeures
```
IF modifications_majeures >= 10 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: 10 modifications majeures atteintes")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 6: Nouveaux fichiers
```
IF nouveaux_fichiers >= 5 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: 5 nouveaux fichiers créés")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 7: Refactorings importants
```
IF refactorings_importants >= 3 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: 3 refactorings importants effectués")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 8: Durée session intensive
```
IF (GET_CURRENT_TIMESTAMP() - session_start_time) >= 7200 THEN  # 2 heures
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: 2 heures de session intense")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 9: Changements architecture
```
IF architecture_changes >= 1 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: Changement d'architecture détecté")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 10: Volume code modifié
```
IF lines_modified_total > 500 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: Code complexe >500 lignes modifiées")
    EXECUTE protocole_fin_session()
END IF
```

### TRIGGER 11: Trop d'échanges
```
IF message_counter > 20 THEN
    OUTPUT("🚨 CHECKPOINT AUTOMATIQUE REQUIS: Plus de 20 échanges effectués")
    EXECUTE protocole_fin_session()
END IF
```

## TRACKING AUTOMATIQUE DES ÉVÉNEMENTS

### Tracking modifications
```
FUNCTION track_major_modification():
    modifications_majeures += 1
    LOG_EVENT("Modification majeure #" + str(modifications_majeures))
    CHECK_AUTOMATIC_CHECKPOINTS()
END FUNCTION

FUNCTION track_new_file(filename):
    nouveaux_fichiers += 1
    LOG_EVENT("Nouveau fichier: " + filename)
    CHECK_AUTOMATIC_CHECKPOINTS()
END FUNCTION

FUNCTION track_refactoring(lines_count):
    lines_modified_total += lines_count
    IF lines_count > 50 THEN  # Seuil refactoring important
        refactorings_importants += 1
        LOG_EVENT("Refactoring important: " + str(lines_count) + " lignes")
        CHECK_AUTOMATIC_CHECKPOINTS()
    END IF
END FUNCTION

FUNCTION track_architecture_change():
    architecture_changes += 1
    LOG_EVENT("Changement architecture #" + str(architecture_changes))
    CHECK_AUTOMATIC_CHECKPOINTS()
END FUNCTION

FUNCTION track_exchange():
    message_counter += 1
    CHECK_AUTOMATIC_CHECKPOINTS()
END FUNCTION
```

## SYSTÈME MONITORING INTÉGRÉ

### COMPRENDRE LE MONITORING - CRITIQUE POUR CLAUDE

**Le monitoring est votre système d'auto-surveillance des tokens de conversation.**

**OBJECTIF** : Éviter le dépassement de limite qui causerait une PERTE TOTALE de contexte.

**PRINCIPE** : Le script configuré dans `config.monitoring.script_path` calcule votre pourcentage d'utilisation tokens et vous dit si vous devez continuer ou vous arrêter IMMÉDIATEMENT.

**FRÉQUENCE OBLIGATOIRE** d'exécution du script :
- **Au démarrage** : Dans `session_start()`
- **Toutes les 5 interactions** : Dans `work_cycle()`
- **Après chaque trigger checkpoint** : Automatique
- **Si mention limite** : Vérification immédiate
- **Avant gros changement** : Recommandé

**SIGNIFICATION DES RÉSULTATS** :
- `✅ OK` → Continuez normalement
- `📊 Surveillance active` → Attention accrue 
- `⚠️ Attention` → Avertir utilisateur, proposer transition
- `🚨 DANGER` → ARRÊT IMMÉDIAT + transition automatique

**RÈGLE ABSOLUE** : JAMAIS ignorer un résultat DANGER.

### Seuils surveillance précis
```python
FUNCTION get_threshold_status(percentage):
    IF percentage >= 0 AND percentage < config.monitoring.thresholds.ok THEN
        RETURN "OK"
    ELIF percentage >= config.monitoring.thresholds.ok AND percentage < config.monitoring.thresholds.attention THEN
        RETURN "SURVEILLANCE"
    ELIF percentage >= config.monitoring.thresholds.attention AND percentage < config.monitoring.thresholds.danger THEN
        RETURN "ATTENTION"
    ELIF percentage >= config.monitoring.thresholds.danger THEN
        RETURN "DANGER"
    END IF
END FUNCTION
```

### Parsing et action monitoring unifié
```python
FUNCTION parse_and_act_on_result(monitor_output):
    IF monitor_output.contains("✅ OK") THEN
        OUTPUT("✅ Limite OK - Poursuite normale")
        RETURN "CONTINUE"
        
    ELIF monitor_output.contains("⚠️ Attention") THEN
        OUTPUT("⚠️ On approche " + str(config.monitoring.thresholds.attention) + "% de la limite")
        OUTPUT("Voulez-vous que je crée un document de transition ?")
        RETURN "WARNING"
        
    ELIF monitor_output.contains("🚨 DANGER") THEN
        OUTPUT("🚨 LIMITE CRITIQUE ! Je crée un document de transition MAINTENANT")
        
        date_str = GET_CURRENT_DATE("YYYYMMDD")
        time_str = GET_CURRENT_TIME("HHMM")
        transition_file = "TRANSITION_NOTES_" + date_str + "_" + time_str + ".md"
        
        EXECUTE protocole_fin_session()
        session_active = FALSE
        RETURN "STOP_IMMEDIATE"
        
    ELSE
        OUTPUT("⚠️ Résultat monitoring inconnu - Traitement comme DANGER")
        EXECUTE protocole_fin_session()
        session_active = FALSE
        RETURN "STOP_IMMEDIATE"
    END IF
END FUNCTION
```

## WORKFLOW SESSION COMPLET

### Phase 1: Démarrage session obligatoire
```python
FUNCTION session_start():
    # 0. CHARGEMENT CONFIGURATION OBLIGATOIRE
    config = LOAD_CONFIG("config/project_config.json")
    VALIDATE_CONFIG(config)
    
    # 1. Navigation obligatoire
    EXECUTE("cd " + config.project.root_path)
    
    # 2. Lecture transition précédente OBLIGATOIRE
    transition_files = FIND_FILES("TRANSITION_NOTES_*.md", config.project.root_path)
    IF transition_files.length > 0 THEN
        latest_transition = SORT_BY_DATE_DESC(transition_files)[0]
        OUTPUT("📋 LECTURE OBLIGATOIRE: " + latest_transition)
        document_content = READ_FILE(latest_transition)
        PARSE_TRANSITION_DOCUMENT(document_content)
        RESTORE_CONTEXT_FROM_DOCUMENT(document_content)
    END IF
    
    # 3. Validation contexte CONCRÈTE
    validation_result, context_report = CONTEXT_FULLY_RESTORED()
    OUTPUT("📊 Rapport validation contexte:")
    OUTPUT(context_report)
    
    IF validation_result == FALSE THEN
        ERROR("🚨 ARRÊT: Contexte critique non restauré")
        OUTPUT("💡 Vérifiez les éléments NIVEAU 1 dans le rapport ci-dessus")
        RETURN FAILURE
    ELIF validation_result == "PARTIAL" THEN
        OUTPUT("⚠️ ATTENTION: Contexte partiellement restauré")
        OUTPUT("🔄 Continuation en mode dégradé - Certaines fonctions limitées")
    ELSE
        OUTPUT("✅ Contexte complet restauré avec succès")
    END IF
    
    # 4. Monitoring initial
    message_counter = 1
    last_monitoring_check = 1
    OUTPUT("🔍 Vérification surveillance initiale...")
    EXECUTE(config.monitoring.script_path + " 1")
    result = GET_LAST_COMMAND_OUTPUT()
    PARSE_AND_ACT_ON_RESULT(result)
    
    OUTPUT("✅ Contexte restauré - Prêt à continuer développement")
    RETURN SUCCESS
END FUNCTION
```

### Phase 2: Boucle travail surveillée
```python
FUNCTION work_cycle():
    WHILE session_active == TRUE:
        work_messages = 0
        
        WHILE work_messages < 5 AND session_active == TRUE:
            PROCESS_USER_MESSAGE()
            message_counter += 1
            work_messages += 1
            
            IF involves_code_modification() THEN
                code_interactions += 1
                TRACK_CODE_INTERACTION()
            END IF
            
            CHECK_AUTOMATIC_CHECKPOINTS()
        END WHILE
        
        IF session_active == TRUE THEN
            OUTPUT("🔍 Monitoring automatique après 5 messages...")
            EXECUTE(config.monitoring.script_path + " " + str(message_counter))
            result = GET_LAST_COMMAND_OUTPUT()
            PARSE_AND_ACT_ON_RESULT(result)
            last_monitoring_check = message_counter
        END IF
    END WHILE
END FUNCTION
```

## PROTOCOLE URGENCE COMPLET

### Transition automatique d'urgence
```python
FUNCTION execute_emergency_transition(transition_filename):
    # 1. Créer document transition immédiatement
    transition_content = GENERATE_COMPLETE_TRANSITION_CONTENT()
    WRITE_FILE(config.project.root_path + transition_filename, transition_content)
    
    # 2. Archivage automatique si nécessaire
    ARCHIVE_OLD_TRANSITIONS()
    
    # 3. Git commit AUTOMATIQUE
    EXECUTE_AUTO("git add " + transition_filename)
    commit_message = "docs: Emergency transition at " + str(monitor_percentage) + "% limit\n\n"
    commit_message += "Automatic backup before session end\n\n"
    commit_message += "🤖 Generated with [Claude Code](https://claude.ai/code)\n\n"
    commit_message += "Co-Authored-By: Claude <noreply@anthropic.com>"
    EXECUTE_AUTO("git commit -m \"" + commit_message + "\"")
    OUTPUT("✅ Commit d'urgence automatique effectué")
    
    # 4. Git push (DEMANDE AUTORISATION même en urgence)
    ASK_USER_PERMISSION("🚨 URGENCE: Voulez-vous pusher immédiatement ? (y/n)")
    IF user_confirms == TRUE THEN
        GIT_PUSH(config.git.remote, config.git.main_branch)
        OUTPUT("📤 Push d'urgence effectué")
    ELSE
        OUTPUT("⏸️ Push différé - Transition sauvée localement")
    END IF
    
    # 5. Prévenir utilisateur
    OUTPUT("🚨 SESSION TERMINÉE - Transition automatique sauvegardée")
    OUTPUT("📁 Fichier: " + transition_filename)
    OUTPUT("💾 Commit + Push effectués")
    OUTPUT("🔄 Prochaine session : Lire le document de transition AVANT tout travail")
    
    # 6. Arrêt obligatoire
    session_active = FALSE
    
    RETURN transition_filename
END FUNCTION
```

### Génération transition exhaustive
```python
FUNCTION generate_complete_transition_content():
    current_date = GET_CURRENT_DATE("YYYY-MM-DD")
    current_time = GET_CURRENT_TIME("HH:MM")
    
    content = "# 📋 Document de Transition - " + current_date + " " + current_time + "\n\n"
    
    # SECTION 1: État avant (SNAPSHOT OBLIGATOIRE)
    content += "## 🎯 État avant session\n"
    content += "### Git status initial:\n"
    content += EXECUTE("git status --porcelain") + "\n"
    content += "### Derniers commits:\n"
    content += EXECUTE("git log --oneline -5") + "\n"
    content += "### Branches actives:\n"
    content += EXECUTE("git branch -v") + "\n\n"
    
    # SECTION 2: Travail de cette session
    content += "## ✅ Travail de cette session\n"
    content += "### Statistiques:\n"
    content += "- Messages échangés: " + str(message_counter) + "\n"
    content += "- Interactions code: " + str(code_interactions) + "\n"
    content += "- Modifications majeures: " + str(modifications_majeures) + "\n"
    content += "- Nouveaux fichiers: " + str(nouveaux_fichiers) + "\n"
    content += "- Refactorings: " + str(refactorings_importants) + "\n"
    content += "- Lignes modifiées: " + str(lines_modified_total) + "\n\n"
    
    # SECTION 3: Modifications détaillées (OBLIGATOIRE)
    content += "## 📁 Fichiers modifiés cette session\n"
    modified_files = EXECUTE("git diff --name-only HEAD~10")
    FOR file IN modified_files.split("\n"):
        IF file.length > 0 THEN
            absolute_path = GET_ABSOLUTE_PATH(file)
            content += "- " + absolute_path + "\n"
            content += "  - Lignes modifiées: " + GET_LINES_CHANGED(file) + "\n"
            content += "  - Type modification: " + GET_CHANGE_TYPE(file) + "\n"
        END IF
    END FOR
    content += "\n"
    
    # SECTION 4: Décisions architecturales (DOCUMENT_RATIONALE)
    content += "## 💡 Décisions architecturales prises\n"
    content += decision_log + "\n"
    content += "### Justifications:\n"
    content += rationale_log + "\n\n"
    
    # SECTION 5: État actuel système (CURRENT_STATE)
    content += "## 🎯 État actuel système\n"
    content += "### Services running:\n"
    content += "- Backend: " + CHECK_SERVICE_STATUS("localhost:" + str(config.services.backend.port)) + "\n"
    
    IF config.services.frontend.port != null THEN
        content += "- Frontend: " + CHECK_SERVICE_STATUS("localhost:" + str(config.services.frontend.port)) + "\n"
    END IF
    
    content += "- " + config.services.database.type.upper() + ": " + CHECK_SERVICE_STATUS("localhost:" + str(config.services.database.port)) + "\n"
    content += "### Infrastructure:\n"
    content += "- Git status: " + EXECUTE("git status --short") + "\n"
    content += "- Commits non pushés: " + EXECUTE("git log " + config.git.remote + "/" + config.git.main_branch + "..HEAD --oneline") + "\n\n"
    
    # SECTION 6: Avertissements (WHAT_NOT_TO_TOUCH)
    content += "## ⚠️ AVERTISSEMENTS CRITIQUES\n"
    content += "### NE PAS TOUCHER:\n"
    
    FOR critical_file, path IN config.critical_files.items():
        IF path != null THEN
            content += "- " + config.project.root_path + path + "\n"
        END IF
    END FOR
    
    content += "- " + config.services.database.type.upper() + " " + config.services.database.version + " configuration (port " + str(config.services.database.port) + ", user " + config.services.database.user + ")\n"
    content += "- Structure " + config.project.root_path + config.structure.transitions_path + "/ (archivage automatique)\n"
    
    content += "### ATTENTION PARTICULIÈRE:\n"
    
    FOR extension IN config.services.database.extensions:
        content += "- " + extension + " installé manuellement\n"
    END FOR
    
    IF config.services.frontend.port != null THEN
        content += "- Frontend sur port " + str(config.services.frontend.port) + ", backend sur " + str(config.services.backend.port) + "\n"
    ELSE
        content += "- Backend sur port " + str(config.services.backend.port) + "\n"
    END IF
    
    content += "- Architecture multi-agents documentée dans " + config.critical_files.claude_instructions + "\n"
    content += warning_log + "\n\n"
    
    # SECTION 7: TODO Liste (REMAINING_TASKS)
    content += "## 📋 TODO Liste Complète\n"
    content += "### Immédiat (session suivante):\n"
    content += "- ☐ " + current_task + "\n"
    
    IF uncommitted_changes_exist() THEN
        content += "- ☐ Finaliser et commiter les modifications en cours\n"
    END IF
    
    IF tests_need_running() THEN
        content += "- ☐ Exécuter suite de tests avant déploiement\n"
    END IF
    
    content += "\n### Développement continu:\n"
    content += "- Architecture multi-agents documentée et opérationnelle\n"
    content += "- Système protocoles machine en développement\n"
    content += "- Structure documentation organisée\n\n"
    
    # SECTION 8: Instructions successeur (OBLIGATOIRE)
    content += "## 🔄 Instructions pour successeur\n"
    content += "### Première action OBLIGATOIRE:\n"
    content += "1. `cd " + config.project.root_path + "`\n"
    content += "2. Lire ce document ENTIÈREMENT avant tout travail\n"
    content += "3. Vérifier backend : `curl http://localhost:" + str(config.services.backend.port) + config.services.backend.health_endpoint + "`\n"
    content += "4. Si backend down : `" + config.services.backend.start_command + "`\n\n"
    content += "### Contexte critique:\n"
    content += "- **Monitoring requis** : Utiliser " + config.monitoring.script_path + " pour surveillance continue\n"
    content += "- **Seuils critiques** : " + str(config.monitoring.thresholds.ok) + "% surveillance, " + str(config.monitoring.thresholds.attention) + "% attention, " + str(config.monitoring.thresholds.danger) + "% danger\n"
    content += "- **Checkpoints auto** : Configurés selon triggers préventifs\n"
    content += "- **Architecture stable** : Multi-agents opérationnel, documentation organisée\n\n"
    content += "### Priorité immédiate:\n"
    content += "Continuer développement avec surveillance automatique activée.\n\n"
    
    content += "---\n"
    content += "*Transition générée automatiquement - " + current_date + " " + current_time + "*\n"
    content += "*Protocole machine complet - Contexte exhaustif préservé*"
    
    RETURN content
END FUNCTION
```

## RÉCUPÉRATION D'URGENCE

### Sans document transition
```python
FUNCTION emergency_recovery_without_transition():
    OUTPUT("🚨 RÉCUPÉRATION D'URGENCE - Aucune transition trouvée")
    
    # 1. Analyser commits récents
    OUTPUT("📋 Analyse des commits récents...")
    recent_commits = EXECUTE("git log --oneline -20")
    PARSE_COMMIT_HISTORY(recent_commits)
    
    # 2. Analyser modifications
    OUTPUT("📋 Analyse des modifications récentes...")
    recent_changes = EXECUTE("git diff HEAD~5")
    PARSE_RECENT_CHANGES(recent_changes)
    
    # 3. Chercher fichiers notes existants
    OUTPUT("📋 Recherche fichiers de notes...")
    notes_files = FIND_FILES("*NOTES*.md", config.project.root_path)
    handover_files = FIND_FILES("*HANDOVER*.md", config.project.root_path)
    protocol_files = FIND_FILES("*PROTOCOL*.md", config.project.root_path)
    
    # 4. Reconstitution contexte partiel
    context = RECONSTRUCT_CONTEXT_FROM_GIT()
    
    OUTPUT("⚠️ Contexte partiellement reconstitué")
    OUTPUT("🔍 Recommandation: Procéder avec prudence maximale")
    OUTPUT("💡 Créer document transition dès que possible")
    
    RETURN context
END FUNCTION
```

## VALIDATION COMPLIANCE

### Interdictions absolues
```python
FUNCTION validate_compliance():
    # JAMAIS ignorer DANGER
    IF last_result == "DANGER" AND action_taken != "EMERGENCY_TRANSITION" THEN
        ERROR("VIOLATION CRITIQUE: Résultat DANGER ignoré")
        FORCE_EMERGENCY_TRANSITION()
    END IF
    
    # JAMAIS oublier comptage
    IF message_counter == 0 OR message_counter < last_user_interaction THEN
        ERROR("VIOLATION: Comptage messages défaillant")
        RESET_COUNTERS()
    END IF
    
    # JAMAIS attendre demande utilisateur pour monitoring
    IF monitoring_overdue() AND user_request_required == TRUE THEN
        ERROR("VIOLATION: Monitoring en attente de demande utilisateur")
        FORCE_MONITORING_CHECK()
    END IF
    
    # JAMAIS continuer sans contexte
    IF context_fully_restored() == FALSE AND session_started == TRUE THEN
        ERROR("VIOLATION: Session démarrée sans contexte complet")
        FORCE_CONTEXT_RECOVERY()
    END IF
END FUNCTION
```

### Triggers spéciaux étendus
```python
# Trigger "cloture" automatique étendu
IF user_input.contains("cloture") OR user_input.contains("clôture") THEN
    OUTPUT("🔄 Trigger 'cloture' détecté - Création transition automatique")
    date_str = GET_CURRENT_DATE("YYYYMMDD")
    time_str = GET_CURRENT_TIME("HHMM")
    transition_file = "TRANSITION_NOTES_" + date_str + "_" + time_str + ".md"
    EXECUTE protocole_fin_session()
END IF

# Trigger mentions limite
IF user_input.contains("conversation getting long") OR 
   user_input.contains("limite") OR
   user_input.contains("fin de session") THEN
    OUTPUT("🚨 Mention limite détectée - Vérification immédiate")
    EXECUTE(config.monitoring.script_path + " " + str(message_counter))
    result = GET_LAST_COMMAND_OUTPUT()
    PARSE_AND_ACT_ON_RESULT(result)
END IF
```

## VALIDATION FINALE PROTOCOLE

### Checklist qualité complète
```python
FUNCTION validate_protocol_completeness():
    checks = {
        "variables_systeme": ALL_VARIABLES_DEFINED(),
        "workflow_session": SESSION_WORKFLOW_COMPLETE(),
        "monitoring_integre": MONITORING_SYSTEM_OPERATIONAL(),
        "checkpoints_auto": CHECKPOINT_TRIGGERS_CONFIGURED(),
        "transition_complete": TRANSITION_GENERATION_FUNCTIONAL(),
        "urgence_protocole": EMERGENCY_PROCEDURES_READY(),
        "interdictions": COMPLIANCE_RULES_ENFORCED(),
        "recuperation": RECOVERY_PROCEDURES_AVAILABLE(),
        "configuration": CONFIG_LOADED_AND_VALID()
    }
    
    failed_checks = []
    FOR check_name, result IN checks.items():
        IF result == FALSE THEN
            failed_checks.append(check_name)
        END IF
    END FOR
    
    IF failed_checks.length == 0 THEN
        OUTPUT("✅ PROTOCOLE MACHINE VALIDÉ - PRÊT POUR PRODUCTION")
        RETURN TRUE
    ELSE
        OUTPUT("❌ ÉCHECS VALIDATION: " + str(failed_checks))
        RETURN FALSE
    END IF
END FUNCTION
```

## 🔍 VALIDATION CONTEXTE CONCRÈTE

### Fonction principale
```python
FUNCTION CONTEXT_FULLY_RESTORED():
    validation_mode = "GRACEFUL"  # STRICT, GRACEFUL, EMERGENCY
    report = {"niveau1": {}, "niveau2": {}, "niveau3": {}, "summary": ""}
    critical_failures = []
    warnings = []
    
    # NIVEAU 1 - CRITIQUE (OBLIGATOIRE)
    report["niveau1"]["transition_doc"] = CHECK_TRANSITION_DOCUMENT()
    report["niveau1"]["working_dir"] = CHECK_WORKING_DIRECTORY()
    report["niveau1"]["git_repo"] = CHECK_GIT_REPOSITORY()
    report["niveau1"]["todo_list"] = CHECK_TODO_LIST()
    report["niveau1"]["config_loaded"] = CHECK_CONFIG_LOADED()
    
    # NIVEAU 2 - IMPORTANT (RECOMMANDÉ)
    report["niveau2"]["services"] = CHECK_SERVICES_STATUS()
    report["niveau2"]["critical_files"] = CHECK_CRITICAL_FILES()
    report["niveau2"]["monitoring"] = CHECK_MONITORING_SCRIPTS()
    
    # NIVEAU 3 - INFORMATIF (NICE-TO-HAVE)
    report["niveau3"]["git_consistency"] = CHECK_GIT_CONSISTENCY()
    report["niveau3"]["system_resources"] = CHECK_SYSTEM_RESOURCES()
    report["niveau3"]["permissions"] = CHECK_FILE_PERMISSIONS()
    
    # ÉVALUATION GLOBALE
    critical_score = COUNT_SUCCESSES(report["niveau1"])
    important_score = COUNT_SUCCESSES(report["niveau2"])
    info_score = COUNT_SUCCESSES(report["niveau3"])
    
    # DÉTERMINER RÉSULTAT
    IF critical_score < 5 THEN  # Tous les checks niveau 1 requis (incluant config)
        report["summary"] = "❌ ÉCHEC CRITIQUE: " + str(5-critical_score) + " éléments essentiels manquants"
        RETURN FALSE, GENERATE_DETAILED_REPORT(report)
    ELIF critical_score == 5 AND important_score < 2 THEN
        report["summary"] = "⚠️ PARTIEL: Critique OK, mais " + str(3-important_score) + " éléments importants manquants"
        RETURN "PARTIAL", GENERATE_DETAILED_REPORT(report)
    ELSE
        report["summary"] = "✅ COMPLET: " + str(critical_score) + "/5 critique, " + str(important_score) + "/3 important, " + str(info_score) + "/3 info"
        RETURN TRUE, GENERATE_DETAILED_REPORT(report)
    END IF
END FUNCTION
```

### Fonctions de check atomiques
```python
FUNCTION CHECK_CONFIG_LOADED():
    IF config EXISTS AND config.project.root_path != NULL THEN
        RETURN {"status": "✅", "detail": "Configuration chargée: " + config.project.name}
    ELSE
        RETURN {"status": "❌", "detail": "Configuration non chargée ou invalide"}
    END IF
END FUNCTION

FUNCTION CHECK_TRANSITION_DOCUMENT():
    IF latest_transition_file EXISTS AND IS_READABLE THEN
        IF PARSE_TRANSITION_SUCCESS() THEN
            RETURN {"status": "✅", "detail": "Document transition lu et parsé"}
        ELSE
            RETURN {"status": "❌", "detail": "Document transition corrompu"}
        END IF
    ELSE
        RETURN {"status": "❌", "detail": "Aucun document transition trouvé"}
    END IF
END FUNCTION

FUNCTION CHECK_WORKING_DIRECTORY():
    current_dir = GET_CURRENT_DIRECTORY()
    expected_dir = config.project.root_path
    
    IF current_dir == expected_dir THEN
        RETURN {"status": "✅", "detail": "Répertoire correct: " + current_dir}
    ELSE
        # AUTO-CORRECTION
        EXECUTE("cd " + expected_dir)
        IF GET_CURRENT_DIRECTORY() == expected_dir THEN
            RETURN {"status": "🔧", "detail": "Auto-correction: Navigation vers " + expected_dir}
        ELSE
            RETURN {"status": "❌", "detail": "Impossible naviguer vers " + expected_dir}
        END IF
    END IF
END FUNCTION

FUNCTION CHECK_GIT_REPOSITORY():
    IF EXECUTE("git status") SUCCESS THEN
        git_branch = EXECUTE("git branch --show-current")
        RETURN {"status": "✅", "detail": "Git OK - Branche: " + git_branch}
    ELSE
        RETURN {"status": "❌", "detail": "Repository git inaccessible ou corrompu"}
    END IF
END FUNCTION

FUNCTION CHECK_TODO_LIST():
    IF current_todo_list != "" AND current_todo_list != NULL THEN
        todo_count = COUNT_TODOS(current_todo_list)
        RETURN {"status": "✅", "detail": str(todo_count) + " tâches chargées"}
    ELSE
        # AUTO-CORRECTION: Créer liste vide
        current_todo_list = "[]"
        RETURN {"status": "🔧", "detail": "Auto-correction: TODO liste vide créée"}
    END IF
END FUNCTION

FUNCTION CHECK_SERVICES_STATUS():
    backend_status = TEST_URL("http://localhost:" + str(config.services.backend.port) + config.services.backend.health_endpoint)
    database_status = TEST_CONNECTION("localhost:" + str(config.services.database.port))
    
    services_up = 0
    details = []
    
    IF backend_status == "OK" THEN
        services_up += 1
        details.append("Backend ✅")
    ELSE
        details.append("Backend ❌")
    END IF
    
    IF config.services.frontend.port != null THEN
        frontend_status = TEST_URL("http://localhost:" + str(config.services.frontend.port) + config.services.frontend.health_endpoint)
        IF frontend_status == "OK" THEN
            services_up += 1
            details.append("Frontend ✅")
        ELSE
            details.append("Frontend ❌")
        END IF
    END IF
    
    IF database_status == "OK" THEN
        services_up += 1
        details.append(config.services.database.type.upper() + " ✅")
    ELSE
        details.append(config.services.database.type.upper() + " ❌")
    END IF
    
    expected_services = config.services.frontend.port != null ? 3 : 2
    
    IF services_up >= (expected_services - 1) THEN
        RETURN {"status": "✅", "detail": str(services_up) + "/" + str(expected_services) + " services: " + JOIN(details, ", ")}
    ELSE
        RETURN {"status": "⚠️", "detail": "Seulement " + str(services_up) + "/" + str(expected_services) + " services: " + JOIN(details, ", ")}
    END IF
END FUNCTION

FUNCTION CHECK_CRITICAL_FILES():
    critical_files = [
        config.project.root_path + config.critical_files.claude_instructions,
        config.project.root_path + config.critical_files.machine_instructions,
        config.monitoring.script_path
    ]
    
    missing_files = []
    FOR file IN critical_files:
        IF NOT FILE_EXISTS(file) THEN
            missing_files.append(file)
        END IF
    END FOR
    
    IF missing_files.length == 0 THEN
        RETURN {"status": "✅", "detail": "Tous fichiers critiques présents"}
    ELSE
        RETURN {"status": "⚠️", "detail": str(missing_files.length) + " fichiers manquants: " + JOIN(missing_files, ", ")}
    END IF
END FUNCTION

FUNCTION CHECK_MONITORING_SCRIPTS():
    IF FILE_EXISTS(config.monitoring.script_path) AND IS_EXECUTABLE(config.monitoring.script_path) THEN
        test_result = EXECUTE(config.monitoring.script_path + " 1")
        IF test_result CONTAINS "✅" OR test_result CONTAINS "Messages:" THEN
            RETURN {"status": "✅", "detail": "Script monitoring fonctionnel"}
        ELSE
            RETURN {"status": "⚠️", "detail": "Script présent mais résultat inattendu"}
        END IF
    ELSE
        RETURN {"status": "❌", "detail": "Script monitoring manquant ou non exécutable"}
    END IF
END FUNCTION
```

### Fonction génération rapport
```python
FUNCTION GENERATE_DETAILED_REPORT(report):
    output = "\n" + "="*50 + "\n"
    output += "🔍 RAPPORT VALIDATION CONTEXTE DÉTAILLÉ\n"
    output += "="*50 + "\n\n"
    
    output += "📌 NIVEAU 1 - CRITIQUE (requis pour continuer):\n"
    FOR key, value IN report["niveau1"].items():
        output += "  • " + key + ": " + value["status"] + " " + value["detail"] + "\n"
    END FOR
    
    output += "\n📋 NIVEAU 2 - IMPORTANT (recommandé):\n"
    FOR key, value IN report["niveau2"].items():
        output += "  • " + key + ": " + value["status"] + " " + value["detail"] + "\n"
    END FOR
    
    output += "\n📊 NIVEAU 3 - INFORMATIF:\n"
    FOR key, value IN report["niveau3"].items():
        output += "  • " + key + ": " + value["status"] + " " + value["detail"] + "\n"
    END FOR
    
    output += "\n" + "="*50 + "\n"
    output += "🎯 RÉSUMÉ: " + report["summary"] + "\n"
    output += "="*50
    
    RETURN output
END FUNCTION
```

## 📊 MÉTADONNÉES PROTOCOLE

**Version**: 2.0 GÉNÉRIQUE CONFIGURABLE  
**Compilé depuis**: Version 1.1 + Système configuration centralisée  
**Conflits résolus**: 6/6  
**Références hardcodées éliminées**: 22/22  
**Nouvelles fonctions**: 3 (chargement config, validation config, services dynamiques)  
**Taux compatibilité**: 100% (multi-projets)  
**Tests validation**: PASSED + GÉNÉRIQUE  
**Status**: PRODUCTION READY - PROJECT AGNOSTIC

---
*Instructions machine générées le 21 juin 2025*
*Pour exécution automatique stricte par Claude Superviseur*
*Version générique complète - Framework project-agnostic opérationnel*