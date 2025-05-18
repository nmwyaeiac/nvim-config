-- lua/plugins/none-ls.lua
return {
  -- Plugin none-ls (anciennement null-ls) pour le formatage et les diagnostics
  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = function()
      local null_ls = require("null-ls")
      
      -- Configure ici tes sources préférées
      local sources = {
        -- Formatage
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        
        -- Diagnostics
        null_ls.builtins.diagnostics.eslint,
        
        -- Code actions
        null_ls.builtins.code_actions.eslint,
      }
      
      return {
        sources = sources,
        on_attach = function(client, bufnr)
          -- Attacher les mappages LSP de l'utilisateur
          require("utils.lsp").apply_user_lsp_mappings(client, bufnr)
        end,
      }
    end,
  },
  
  -- Plugin mason-null-ls pour installer automatiquement les formatters/linters
  {
    "jay-babu/mason-null-ls.nvim",
    event = "BufReadPre",
    opts = {
      ensure_installed = {
        "prettier",     -- JS/TS/HTML/CSS
        "stylua",       -- Lua
        "black",        -- Python
        "eslint_d",     -- JS/TS
      },
      automatic_installation = true,
      handlers = {},
    },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
  },
}
