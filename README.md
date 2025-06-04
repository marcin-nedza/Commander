# Commander.nvim

**Commander.nvim** is a simple Neovim plugin that allows you to send frequently used shell commands directly to a specific [tmux](https://github.com/tmux/tmux) pane—without leaving Neovim. Just press a keybinding, and Commander takes care of the rest.

> Ideal for workflows where you keep code in one pane and your terminal in another.

---

## ✨ Features

- ⌨️ Bind your most-used shell commands to custom keybindings.
- 🔁 Automatically send those commands to a specified tmux pane.
- 🧠 No need to manually switch panes or retype commands.
- 🛠 Easily configurable with zero dependencies beyond tmux and Neovim.

---

## ⚙️ Example Usage

https://github.com/user-attachments/assets/5bf3cfc8-1dde-426b-aef2-943ded647e0a



---
## 📦 Installation

Using **lazy.nvim**:

```lua
{
  "marcin-nedza/Commander",
  config = function()
    require("commander").setup()
  end,
}
```
Or with **packer.nvim**:



```lua
use {
  "marcin-nedza/Commander",
  config = function()
    require("commander").setup()
  end,
}
```
## ⚙️ Configuration

Commander.nvim stores keybindings and commands in a JSON file at:
~/.local/share/nvim/test/commands.json
The format supports **project-specific** commands. Here's an example:

````json
{
  "/home/user/location1": [
    {
      "pane": 1,
      "keybind": "b",
      "command": "gcc main.c -o main"
    },
    {
      "pane": 2,
      "keybind": "r",
      "command": "./main"
    }
  ],
  "/home/user/location2": [
    {
      "pane": 2,
      "keybind": "s",
      "command": "npm start"
    }
  ]
}
````
- `pane`: Target tmux pane number.
- `keybind`: The Neovim key (single character) to trigger the command (prefixed with your chosen leader key).
- `command`: The shell command to send.

> Each path corresponds to a project directory. When you're working inside that directory, Commander loads the appropriate bindings.

## ⚙️ Customizing the Leader Key for plugin

By default, Commander.nvim uses `<C-s>` (Control + s) as the leader key for all command keybindings.

You can customize the leader key by passing an option when setting up the plugin:

```lua
require("commander").setup({
    leader_key = "<C-w>" -- Replace with your preferred leader key
})
```
### Default keybindings:

- `<leader>o` — Opens a floating window listing your saved commands.
- `<leader>i` — Opens a prompt to insert a new command.
- `<leader>k` — Shows available tmux panes.
---

## 🚀 Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request on GitHub.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
