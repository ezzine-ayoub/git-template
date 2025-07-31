# Daisy Pre-commit Hooks Template

🔧 **Template parfait pour les hooks Git avec prise en charge Windows complète**

Ce template fournit un ensemble complet de hooks Git configurés pour les projets Odoo utilisant les hooks de qualité de code Daisy. Entièrement compatible avec Windows (Git Bash), WSL, Linux et macOS.

## 🚀 Installation Rapide

### Option 1: Script d'installation automatique
```bash
# Dans votre projet Git
./setup-hooks.sh
```

### Option 2: Installation manuelle
```bash
# Copier les fichiers vers votre projet
cp .git-templates/hooks/* /votre-projet/.git/hooks/
chmod +x /votre-projet/.git/hooks/*

# Installer pre-commit
pip install pre-commit
pre-commit install
```

## 📁 Structure des Fichiers

```
.git-templates/hooks/
├── shared-functions.sh     # Fonctions communes partagées
├── post-checkout          # Setup automatique après clone/checkout
├── pre-commit            # Validation avant commit
├── pre-merge             # Contrôles avant merge
├── pre-push              # Vérifications avant push
├── setup-hooks.sh        # Script d'installation
└── README.md            # Cette documentation
```

## 🔍 Fonctionnalités des Hooks

### `post-checkout`
- ✅ Configuration automatique après clone
- ✅ Création du fichier `.pre-commit-config.yaml` par défaut
- ✅ Installation automatique de pre-commit
- ✅ Vérification initiale non-bloquante

### `pre-commit`
- ✅ Validation de la configuration
- ✅ Contrôles de qualité du code
- ✅ Blocage des commits défaillants
- ✅ Messages d'erreur clairs

### `pre-merge`
- ✅ Contrôles complets avant fusion
- ✅ Validation sur tous les fichiers
- ✅ Protection des branches principales

### `pre-push` 
- ✅ Vérifications finales avant push
- ✅ Contrôle de la qualité globale
- ✅ Protection du repository distant

## 🖥️ Compatibilité

| Système | Support | Recommandation |
|---------|---------|----------------|
| **Windows** | ✅ Complet | Utiliser Git Bash |
| **Linux** | ✅ Natif | Fonctionne directement |
| **macOS** | ✅ Natif | Fonctionne directement |
| **WSL** | ✅ Natif | Environnement Linux dans Windows |

## ⚙️ Configuration

### Configuration pre-commit par défaut
```yaml
exclude: 'daisy-pre-commit-hooks/scripts/.*|odoo18/(check_manifest|wait-for-psql)\.py|check_duplicate_ids\.py|.idea/.*'
repos:
  - repo: https://github.com/Daisy-Consulting/daisy-pre-commit-hooks
    rev: v1.1.5
    hooks:
      - id: check-xml-header
      - id: check-manifest-fields
      - id: check-sudo-comment
      - id: detect-raw-sql-delete-insert
      - id: check_duplicate_method_names
      - id: check-for-return
      - id: check-xml-closing-tags
      - id: check-report-template
      - id: check-compute-function
      - id: check-duplicate-ids
```

### Validation automatique
Les hooks vérifient automatiquement :
- ✅ Présence du repository Daisy hooks
- ✅ Version correcte (v1.1.5)
- ✅ Configuration du hook `check-manifest-fields`
- ✅ Compatibilité avec les URLs anciennes et nouvelles

## 🛠️ Utilisation

### Commits normaux
```bash
git commit -am "Votre message"
# Les hooks s'exécutent automatiquement
```

### Bypasser les hooks (si nécessaire)
```bash
git commit --no-verify -am "Message urgent"
git push --no-verify
```

### Exécuter les hooks manuellement
```bash
pre-commit run              # Sur les fichiers modifiés
pre-commit run --all-files  # Sur tous les fichiers
```

## 🔧 Résolution des Problèmes

### Erreur "Executable not found"
**Windows :** Utilisez Git Bash au lieu de PowerShell
```bash
# ❌ PowerShell
PS C:\> git commit -am "test"

# ✅ Git Bash  
$ git commit -am "test"
```

### Pre-commit non installé
```bash
pip install pre-commit
pre-commit install
```

### Permissions sur Linux/macOS
```bash
chmod +x .git/hooks/*
```

### Réinstaller les hooks
```bash
rm .git/hooks/pre-commit .git/hooks/post-checkout .git/hooks/pre-merge .git/hooks/pre-push
./setup-hooks.sh
```

## 🎯 Fonctionnalités Avancées

### Détection automatique de l'OS
Les hooks détectent automatiquement votre système d'exploitation et s'adaptent.

### Messages colorés
- 🔵 **Info** : Messages informatifs
- ✅ **Succès** : Opérations réussies  
- ⚠️ **Avertissement** : Actions recommandées
- ❌ **Erreur** : Problèmes bloquants

### Fonctions partagées
Toute la logique commune est centralisée dans `shared-functions.sh` pour faciliter la maintenance.

### Configuration flexible
Support des anciennes et nouvelles URLs de repository pour une migration en douceur.

## 📝 Développement

### Ajouter un nouveau hook
1. Créer le hook dans `.git-templates/hooks/`
2. Ajouter `#!/usr/bin/env bash` en première ligne
3. Sourcer les fonctions partagées :
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"
```
4. Utiliser les fonctions `print_*` pour les messages
5. Ajouter le hook au script `setup-hooks.sh`

### Fonctions disponibles
```bash
detect_os()              # Détecte le système d'exploitation
get_project_name()       # Récupère le nom du projet
check_precommit_config() # Valide la configuration
install_precommit()      # Install les hooks pre-commit
run_precommit()         # Exécute pre-commit
print_info()            # Message informatif
print_success()         # Message de succès
print_warning()         # Message d'avertissement
print_error()           # Message d'erreur
```

## 🏷️ Versions

- **v1.0** : Template de base
- **v1.1** : Support Windows complet
- **v1.2** : Fonctions partagées et script d'installation
- **v1.3** : Support URLs multiples et messages améliorés

## 🤝 Contribution

Pour contribuer à ce template :
1. Fork le repository
2. Créer une branche feature
3. Tester sur Windows, Linux et macOS
4. Soumettre une pull request

---

**Made with ❤️ by Daisy Consulting Team**
