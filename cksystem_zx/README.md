# CK System - Character Kill System

**Author:** Zyrox | **Version:** 1.0.0 | **Framework:** ESX & QB-Core

Character Kill System for FiveM servers - allows admins to delete player characters with security confirmation. Supports ESX & QB-Core, multilingual (CS/EN/DE/ES/FR), ox_lib dialogs & configurable permissions.

## 🚀 Installation

1. Copy `cksystem_zx` to resources folder
2. Add `ensure cksystem_zx` to server.cfg
3. Dependencies: `ox_lib`, `oxmysql`

## ⚙️ Configuration

```lua
Config.Framework = 'auto'
Config.AllowedGroups = {'admin', 'superadmin', 'mod', 'moderator'}
Config.AllowedGroupsInsta = {'superadmin'}
Config.Locale = 'en'
```

## 🎮 Commands

- `/ck [ID]` - CK with confirmation (admin+)
- `/ckinsta [ID]` - Instant CK (superadmin only)

## 🌍 Languages
CS, EN, DE, ES, FR

---
**⚠️ WARNING:** This script permanently deletes data from database!
