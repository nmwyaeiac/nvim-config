-- lua/plugins/optional-deps.lua
-- Ce fichier gère l'installation des dépendances optionnelles

return {
  -- Installation optionnelle de csharpier pour C#
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      -- S'assurer que la table ensure_installed existe
      opts.ensure_installed = opts.ensure_installed or {}
      
      -- Remplacer csharpier par dotnet-csharpier
      for i, item in ipairs(opts.ensure_installed) do
        if item == "csharpier" then
          opts.ensure_installed[i] = "dotnet-csharpier"
          break
        end
      end
      
      return opts
    end,
  },
  
  -- Patch pour les avertissements de dépréciation
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function(_, opts)
      -- Appliquer le patch de compatibilité avant le chargement de null-ls
      local compat = require("utils.compat-improved")
      local restore_validate = compat.patch_validate_calls()
      
      -- Configurer null-ls normalement
      require("null-ls").setup(opts or {})
      
      -- Restaurer la fonction originale (optionnel)
      -- restore_validate()
    end,
  },
  
  -- Patch pour alpha-nvim
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Appliquer le patch de compatibilité pour vim.validate
      local compat = require("utils.compat-improved")
      local restore_validate = compat.patch_validate_calls()
      
      -- Configurer alpha normalement
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.startify")
      
      dashboard.section.header.val = {
        [[                                                                       ]],
        [[                                                                       ]],
        [[                                                                       ]],
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████           █████      ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
        [[                                                                       ]],
        [[                                                                       ]],
        [[                                                                       ]],
      }
      
      alpha.setup(dashboard.opts)
      
      -- Restaurer la fonction originale (optionnel)
      -- restore_validate()
    end,
  },
  
  -- Patch pour mason-nvim-dap
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function(_, opts)
      -- Appliquer le patch de compatibilité avant la configuration
      local compat = require("utils.compat-improved")
      local restore_validate = compat.patch_validate_calls()
      
      -- Configurer mason-nvim-dap normalement
      require("mason-nvim-dap").setup(opts or {
        ensure_installed = {
          "python",
          "cppdbg",
          "codelldb",
          "js",
          "bash",
        },
        automatic_installation = true,
        automatic_setup = true,
      })
      
      -- Restaurer la fonction originale (optionnel)
      -- restore_validate()
    end,
  },
}
