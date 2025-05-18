-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { 
        -- Liste de parsers spécifiques à installer au lieu de "all"
        -- qui peut consommer beaucoup de ressources
        "lua", "vim", "vimdoc", -- Pour Neovim
        "python", "c", "cpp", "rust", "go", -- Langages courants
        "javascript", "typescript", "html", "css", "json", -- Web
        "bash", "markdown", "markdown_inline", -- Utilitaires
        -- Ajoutez ici d'autres parsers selon vos besoins
      },
      -- Installer automatiquement les parsers manquants lors de l'ouverture de fichiers
      auto_install = true,
      highlight = { 
        enable = true,
        -- Désactiver pour les très grands fichiers
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-backspace>",
        },
      },
    })
    
    -- Vérifier la présence de l'exécutable tree-sitter
    if vim.fn.executable("tree-sitter") == 0 then
      vim.notify(
        "L'exécutable tree-sitter n'est pas trouvé. Vous pouvez l'installer avec 'npm install -g tree-sitter-cli' si nécessaire pour :TSInstallFromGrammar.",
        vim.log.levels.INFO
      )
    end
  end,
}
