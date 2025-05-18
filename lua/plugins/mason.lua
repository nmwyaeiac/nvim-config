-- lua/plugins/mason.lua
-- Configuration compatible avec Mason v1.11.0
return {
  -- Gestionnaire de serveurs LSP, DAP, linters et formatters
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 100, -- Chargement prioritaire
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
          border = "rounded",
          keymaps = {
            -- Mappages par défaut pour naviguer dans l'interface Mason
            toggle_package_expand = "<CR>",
            install_package = "i",
            update_package = "u",
            check_package_version = "c",
            update_all_packages = "U",
            check_outdated_packages = "C",
            uninstall_package = "X",
            cancel_installation = "<C-c>",
            apply_language_filter = "<C-f>",
          },
        },
        max_concurrent_installers = 4, -- Nombre max d'installations simultanées
        log_level = vim.log.levels.INFO,
        
        -- Ne pas installer automatiquement lors du setup - on utilisera mason-lspconfig pour ça
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
      })
      
      -- Afficher un message de succès
      vim.notify("Mason configuré avec succès (v1.11.0)", vim.log.levels.INFO)
    end,
  },

  -- Intégration entre Mason et LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { 
      "williamboman/mason.nvim", 
      "neovim/nvim-lspconfig"
    },
    event = "BufReadPre",
    config = function()
      -- Configuration explicite pour Mason 1.x
      require("mason-lspconfig").setup({
        -- Liste des serveurs à installer automatiquement
        ensure_installed = {
          "clangd",          -- C/C++
          "pyright",         -- Python
          "html",            -- HTML
          "cssls",           -- CSS
          "lua_ls",          -- Lua
          "jsonls",          -- JSON
          "yamlls",          -- YAML
          "tsserver",        -- TypeScript/JavaScript
        },
        -- Installation automatique des serveurs
        automatic_installation = true,
      })
      
      -- Configuration des serveurs LSP - compatible avec v1.11.0
      local lsp_util = require("utils.lsp")
      lsp_util.apply_default_lsp_settings()
      
      -- Handler personnalisé pour chaque serveur
      require("mason-lspconfig").setup_handlers({
        -- Gestionnaire par défaut
        function(server_name)
          -- Ignorer jdtls car il est géré séparément par nvim-java
          if server_name ~= "jdtls" then
            lsp_util.setup(server_name)
          end
        end,
        
        -- Gestionnaires spécifiques (facultatif)
        ["lua_ls"] = function()
          -- Configuration spéciale pour lua_ls si nécessaire
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" }, -- Reconnaître vim comme une variable globale
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false, -- Éviter le popup sur le démarrage
                },
                telemetry = {
                  enable = false,
                },
              },
            },
            on_attach = function(client, bufnr)
              lsp_util.apply_user_lsp_mappings(client, bufnr)
            end,
          })
        end,
      })
      
      -- Déclencher un événement pour que les serveurs LSP démarrent sur les buffers actuels
      vim.defer_fn(function()
        vim.cmd("doautocmd FileType")
      end, 100)
    end,
  },

  -- Mason-nvim-dap pour les adaptateurs de débogage
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Configuration de mason-nvim-dap - compatible avec v1.x
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "python",      -- Python (debugpy)
          "cppdbg",      -- C/C++ (GDB)
          "codelldb",    -- Rust, C/C++
        },
        automatic_installation = true,
        
        -- Configuration des adaptateurs
        handlers = {
          function(config)
            -- Gestionnaire par défaut - installer et configurer automatiquement
            require("mason-nvim-dap").default_setup(config)
          end,
          
          -- Ajoutez des gestionnaires personnalisés ici si nécessaire
        },
      })
    end,
  },
  
  -- Configuration pour java - séparée de mason-lspconfig
  {
    "zeioth/nvim-java",
    ft = { "java" },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mason-org/mason.nvim",
    },
    opts = {
      notifications = {
        dap = false,
      },
      -- Marqueurs racine pour les projets Java
      root_markers = {
        "settings.gradle",
        "settings.gradle.kts",
        "pom.xml",
        "build.gradle",
        "mvnw",
        "gradlew",
        "build.gradle",
        "build.gradle.kts",
        ".git",
      },
    },
  },
  
  -- On ajoute SchemaStore ici plutôt que comme dépendance pour éviter les problèmes
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  }
}
