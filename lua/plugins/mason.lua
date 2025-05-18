-- lua/plugins/mason.lua
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

  -- Intégration entre Mason et LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { 
      "williamboman/mason.nvim", 
      "neovim/nvim-lspconfig"
    },
    event = "BufReadPre",
    opts = {
      -- Serveurs LSP à installer automatiquement (liste à adapter selon vos besoins)
      ensure_installed = {
        "clangd",          -- C/C++
        "pyright",         -- Python
        "html",            -- HTML
        "cssls",           -- CSS
        "tsserver",        -- TypeScript/JavaScript
        "eslint",          -- JavaScript/TypeScript linting
        "lua_ls",          -- Lua
        "jsonls",          -- JSON
        "yamlls",          -- YAML
      },
      -- Installation automatique des serveurs
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      
      -- Capturer l'événement setup du serveur pour configurer avec notre utilitaire LSP
      require("mason-lspconfig").setup_handlers({
        function(server)
          require("utils.lsp").setup(server)
        end
      })
    end,
  },

  -- Mason-nvim-dap pour les adaptateurs de débogage
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
      ensure_installed = {
        "python",      -- Python (debugpy)
        "cppdbg",      -- C/C++ (GDB)
        "codelldb",    -- Rust, C/C++
      },
    },
  },
}
