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

Commander.nvim stores by default keybindings and commands in a JSON file at:
~/.local/share/nvim/commander.json

This can be changed in config file.

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

## ⚙️ Setup options

By default, Commander.nvim uses `<C-s>` (Control + s) as the leader key for all command keybindings.

You can customize the leader key and other configurations by passing an option when setting up the plugin:

```lua
require("commander").setup({

    command_file_path = "path/to/.local/share/nvim",                -- Default location
    file_name = "commander.json",                                   -- Default file name
    leader_key = "<C-s>",                                           -- Default leader key
    open_list = "o",                                                -- Default key to open list of commands
    insert_new = "i",                                               -- Default key to insert new command
    show_panes = "k",                                               -- Default key to show pane numbers
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
