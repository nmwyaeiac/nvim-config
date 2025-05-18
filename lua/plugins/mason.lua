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
      -- Assurons-nous que tous les noms sont corrects
      ensure_installed = {
        "clangd",          -- C/C++
        "pyright",         -- Python
        "html",            -- HTML
        "cssls",           -- CSS
        "jdtls",           -- Java (remplace "java-language-server")
        "lua_ls",          -- Lua
        "jsonls",          -- JSON
        "yamlls",          -- YAML
        "tsserver",        -- TypeScript/JavaScript - vérifié avec les noms de mason-lspconfig
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      
      -- Configurer les serveurs avec notre utilitaire LSP
      require("mason-lspconfig").setup_handlers({
        function(server)
          -- Ne pas configurer jdtls via lspconfig, il est géré différemment
          if server ~= "jdtls" then
            require("utils.lsp").setup(server)
          end
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
