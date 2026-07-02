# White-Label Update to Chinna-Free-Claude

## Overview
This document outlines all changes made to white-label the application from "Free Claude Code" to "Chinna-Free-Claude" with the new GitHub repository URL `https://github.com/pichimail/free-claude-code`.

**Status**: ✅ All changes applied successfully. Backend flow remains intact. Server running on port 8082.

---

## Changes Made

### 1. **Project Metadata** (`pyproject.toml`)
- **Name**: `free-claude-code` → `chinna-free-claude`
- **Description**: Updated to reference "Chinna Free Claude"
- **Impact**: Package name updated; no backend logic changes

### 2. **Installation Scripts**

#### `scripts/install.sh`
- **REPO_GIT_URL**: `git+https://github.com/Alishahryar1/free-claude-code.git` → `git+https://github.com/pichimail/free-claude-code.git`
- **Impact**: Installation now pulls from new repository

#### `scripts/install.ps1`
- **RepoGitUrl**: `git+https://github.com/Alishahryar1/free-claude-code.git` → `git+https://github.com/pichimail/free-claude-code.git`
- **Impact**: Windows PowerShell installation updated

### 3. **README.md** (Comprehensive Updates)

#### Title & Badges
- Main title: `# 🤖 Free Claude Code` → `# 🤖 Chinna-Free-Claude`
- Pytest badge link updated to new repository
- Description updated to reference Chinna-Free-Claude

#### Quick Start Section
- **macOS/Linux installation**:
  ```bash
  # Old
  curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh
  
  # New
  curl -fsSL "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.sh" | sh
  ```

- **Windows PowerShell installation**:
  ```powershell
  # Old
  irm "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.ps1?raw=1" | iex
  
  # New
  irm "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.ps1" | iex
  ```

- **Uninstall commands**: Updated to use new GitHub URL (raw.githubusercontent.com)
- **Reference links**: All GitHub repository links updated

#### Star History
- Chart reference updated from `Alishahryar1/free-claude-code` to `pichimail/free-claude-code`

#### Voice Installation
- All voice installation command URLs updated to new repository

#### Development Section
- Git clone command updated: `git clone https://github.com/pichimail/free-claude-code.git`

### 4. **User-Facing Components**

#### `api/admin_static/index.html`
- **Page title**: `Free Claude Code Admin` → `Chinna-Free-Claude Admin`
- **Sidebar brand**: `Free Claude Code` → `Chinna-Free-Claude`
- **Impact**: Updated when Admin UI is viewed in browser

#### `cli/launchers/claude.py`
- **Docstring**: Updated to reference Chinna-Free-Claude proxy

#### `cli/launchers/codex.py`
- **Docstring**: Updated to reference Chinna-Free-Claude proxy configuration

#### `cli/launchers/codex_model_catalog.py`
- **Model description**: Updated to "Chinna-Free-Claude provider model"

### 5. **Configuration & Documentation**

#### `api/admin_config/persistence.py`
- **Comment**: Updated from "Managed by Free Claude Code /admin" to "Managed by Chinna-Free-Claude /admin"

#### `config/paths.py`
- **Module docstring**: Updated filesystem paths reference

#### `ARCHITECTURE.md`
- **Title reference**: Updated documentation title

### 6. **Tests**

#### `tests/scripts/test_uninstallers.py`
- **URL validation**: Updated test assertions to verify new GitHub repository URL
- Old assertion: `Alishahryar1/free-claude-code/main/scripts/uninstall.sh`
- New assertion: `pichimail/free-claude-code/main/scripts/uninstall.sh`

---

## Installation & Quick Start (Updated)

### 1. **Install/Update on macOS/Linux**
```bash
curl -fsSL "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.sh" | sh
```

### 2. **Install/Update on Windows PowerShell**
```powershell
irm "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.ps1" | iex
```

### 3. **Start the Server**
```bash
fcc-server
```

**Admin UI**: `http://127.0.0.1:8082/admin` (local-only access)

### 4. **Install with Voice Support**

**macOS/Linux with NVIDIA NIM transcription:**
```bash
curl -fsSL "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.sh" | sh -s -- --voice-nim
```

**macOS/Linux with Local Whisper:**
```bash
curl -fsSL "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.sh" | sh -s -- --voice-local
```

**Windows PowerShell with Voice:**
```powershell
& ([scriptblock]::Create((irm "https://github.com/pichimail/free-claude-code/raw/main/scripts/install.ps1"))) -VoiceNim
```

### 5. **Run Claude Code Through Proxy**
```bash
fcc-claude
```

### 6. **Run Codex Through Proxy**
```bash
fcc-codex
```

---

## Files Changed Summary

| File | Changes | Status |
|------|---------|--------|
| `pyproject.toml` | Name, description | ✅ |
| `scripts/install.sh` | Repository URL | ✅ |
| `scripts/install.ps1` | Repository URL | ✅ |
| `README.md` | Title, links, instructions (15+ updates) | ✅ |
| `api/admin_static/index.html` | Title, sidebar branding | ✅ |
| `cli/launchers/claude.py` | Docstring | ✅ |
| `cli/launchers/codex.py` | Docstring | ✅ |
| `cli/launchers/codex_model_catalog.py` | Model description | ✅ |
| `api/admin_config/persistence.py` | Comment | ✅ |
| `config/paths.py` | Module docstring | ✅ |
| `ARCHITECTURE.md` | Title reference | ✅ |
| `tests/scripts/test_uninstallers.py` | URL assertions | ✅ |

---

## Backend Integrity ✅

- **No API endpoints modified**
- **No provider logic changed**
- **No routing logic affected**
- **No database schema changes**
- **No security changes**
- **All CLI commands remain the same** (fcc-server, fcc-claude, fcc-codex, fcc-init)
- **Config structure unchanged**
- **Admin UI functionality preserved**

---

## Server Status

✅ **Running**: PID 21624  
✅ **Port**: 8082  
✅ **Health**: Responsive (`/health` returns `{"status":"healthy"}`)  
✅ **Admin UI**: Accessible at `http://127.0.0.1:8082/admin`  

---

## Verification Checklist

- [x] All GitHub URLs updated from `Alishahryar1` to `pichimail`
- [x] Project name updated in pyproject.toml
- [x] README installation commands updated
- [x] Admin UI title and branding updated
- [x] CLI launcher docstrings updated
- [x] Tests updated for new URLs
- [x] No breaking changes to backend
- [x] Server health check passing
- [x] No remaining references to old repository

---

## Rolling Back (If Needed)

If you need to revert to the original Free Claude Code:
1. Restore `pyproject.toml` project name to `free-claude-code`
2. Restore GitHub URLs in scripts from `pichimail` to `Alishahryar1`
3. Restore README and other files to original references

Or simply clone the original: `git clone https://github.com/Alishahryar1/free-claude-code.git`

---

## Next Steps

1. **Test installations**: Run the new install commands on different OS types
2. **Verify connections**: Test Claude Code, Codex, and Admin UI through the proxy
3. **Update documentation**: Share the new repository URL with users
4. **Git commit**: Push these changes to the new repository at `https://github.com/pichimail/free-claude-code`

