-- lua/plugins/mason-new.lua
return {
  -- Gestionnaire de serveurs LSP, DAP, linters et formatters
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 100, -- Chargement prioritaire
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      },
      -- Afficher un message quand l'installation est terminée
      log_level = vim.log.levels.INFO,
    },
  },

  -- Intégration entre Mason et LSP config - avec les nouvelles API de 2.0.0
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = "BufReadPre",
    opts = {
      -- Serveurs LSP à installer automatiquement
      ensure_installed = {
        -- C/C++
        "clangd",

        -- Python
        "pyright",

        -- Web
        "html",
        "cssls",
        "tsserver",
        "eslint",

        -- PHP
        "phpactor",

        -- Ruby
        "solargraph",

        -- C#
        "omnisharp",

        -- Zig
        "zls",

        -- Shell
        "bashls",

        -- Rust
        "rust_analyzer",

        -- Lua
        "lua_ls",

        -- Autres
        "jsonls",
        "marksman",
        "yamlls",
      },
      -- Nouvelle configuration pour l'activation automatique 
      automatic_enable = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      
      -- Configuration pour chaque serveur LSP
      -- La gestion des handlers a été supprimée dans la v2.0.0
      -- On utilise maintenant lspconfig directement
      local lspconfig = require("lspconfig")
      local get_servers = require("mason-lspconfig").get_installed_servers

      -- Charger les utilitaires LSP personnalisés
      local utils_lsp = require("utils.lsp")
      
      -- Appliquer les réglages LSP par défaut
      utils_lsp.apply_default_lsp_settings()
      
      -- Configurer chaque serveur installé
      for _, server_name in ipairs(get_servers()) do
        local server_opts = utils_lsp.apply_user_lsp_settings(server_name)
        lspconfig[server_name].setup(server_opts)
      end
    end,
  },

  -- Intégration entre Mason et les outils de formatage/diagnostic
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      -- Formatters et linters à installer automatiquement
      ensure_installed = {
        -- Formatters
        "prettier", -- JS/TS/HTML/CSS
        "stylua", -- Lua
        "black", -- Python
        "clang-format", -- C/C++
        "phpcsfixer", -- PHP
        "rubocop", -- Ruby
        "csharpier", -- C#
        "shfmt", -- Bash
        "google-java-format", -- Java

        -- Linters
        "mypy", -- Python type checking
        "pylint", -- Python
        "eslint_d", -- JavaScript
        "shellcheck", -- Bash
        "phpcs", -- PHP
        "checkstyle", -- Java
      },
      automatic_installation = true,
      handlers = {},
    },
  },

  -- Intégration entre Mason et DAP
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      -- Débogueurs à installer automatiquement
      ensure_installed = {
        "python", -- Python (debugpy)
        "cppdbg", -- C/C++ (GDB)
        "codelldb", -- Rust, C/C++
        "js", -- JavaScript/TypeScript
        "bash-debug-adapter", -- Bash
        "javadbg", -- Java
        "netcoredbg", -- C#
      },
      automatic_installation = true,
      automatic_setup = true,
    },
  },
}
