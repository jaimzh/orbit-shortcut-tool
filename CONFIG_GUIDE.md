# Orbit Shortcut Configuration Guide

This guide explains how to customize your Orbit tool by editing or creating shortcut JSON files.

## 📁 JSON Structure

The configuration is a list of "actions". Each action represents a "planet" in the orbit.

```json
[
  {
    "icon": "save",
    "label": "Save",
    "keys": ["CTRL", "S"]
  },
  {
    "icon": "home",
    "label": "Home",
    "keys": ["WIN", "D"]
  }
]
```

---

## 🛠 Fields

| Field   | Type   | Description                                                                                               |
| :------ | :----- | :-------------------------------------------------------------------------------------------------------- |
| `icon`  | String | The name of the icon to display (see **Available Icons** below).                                          |
| `label` | String | The text that appears when you hover over the planet.                                                     |
| `keys`  | Array  | A list of keys to press simultaneously. Order matters for modified keys (e.g., `["CTRL", "SHIFT", "S"]`). |

---

## 🔑 Supported Keys

You can use the following strings in the `"keys"` array:

### Modifiers

- `CTRL` or `CONTROL`
- `SHIFT`
- `ALT`
- `WIN` or `COMMAND` or `META`

### Letters & Numbers

- `A` through `Z`
- `0` through `9`

### Functional & Navigation

- `ENTER`, `SPACE`, `ESCAPE`, `TAB`, `BACKSPACE`
- `DELETE`, `INSERT`, `HOME`, `END`, `PAGEUP`, `PAGEDOWN`
- `LEFT`, `RIGHT`, `UP`, `DOWN`
- `F1` through `F12`

### Symbols

- `[` and `]`
- `;`, `'`, `,`, `.`, `/`, `\`
- `=`, `-`

---

## 🎨 Available Icons

Orbit uses Material Design icons. Use these names in the `"icon"` field:

- **General:** `save`, `edit`, `delete`, `search`, `refresh`, `settings`, `public`, `star`, `home`, `rocket`
- **Editing:** `undo`, `redo`, `brush`, `copy`, `paste`, `cut`
- **Files/Media:** `file`, `folder`, `image`, `video`, `music`
- **Math/UI:** `add` (plus), `remove` (minus)

---

## 🚀 How to Load

1. Create a `.json` file with your config.
2. Open Orbit.
3. **Right-click** the center icon.
4. Select **Load**.
5. Pick your file. It will update instantly!

> **Refining active config:** If you manually edit the `shortcuts.json` file in your `Documents/OrbitShortcuts/` folder, just click **Reload** in the menu to see the changes.
