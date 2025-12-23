today.nvim
Minimalist daily note plugin for Neovim.

### Installation

LazyVim
```
  {
    "Mazide/today.nvim",
    opts = {
      folderpath = "~/Desktop/Notes/",
    },
  }
```

### Usage

:TodayOpen and :Today — Create/Open daily note in the current buffer
:TodayToggle - Create/Open daily note in a floating window. (q - Close window and auto-save)

### Configuration
Default settings:
```
folderpath = nil,
templatepath = "plugin_root/template.md",
window = {
  width = 0.7,
  height = 0.7,
  border = "rounded",
  title = "Today",
}
```
