return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local null_ls = require("null-ls")
      local lspconfig = require("lspconfig")
      
      -- Sources de formatage et de diagnostic
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local code_actions = null_ls.builtins.code_actions
      local sources = {}

      -- Fonction helper améliorée pour tester si l'outil est installé
      local function try_add(builtin)
        if builtin then
          local cmd = builtin._opts and (builtin._opts.command or builtin._opts.cmd) or builtin.name
          if cmd and vim.fn.executable(cmd) == 1 then
            table.insert(sources, builtin)
            return true
          end
        end
        return false
      end

      -- C/C++
      try_add(formatting.clang_format)
      try_add(diagnostics.clang_check)
      try_add(diagnostics.cppcheck) -- Ajout pour une meilleure analyse C/C++

      -- Java 
      try_add(formatting.google_java_format)
      try_add(diagnostics.checkstyle) -- Ajout pour les diagnostics Java
      
      -- Python
      try_add(formatting.black)
      try_add(diagnostics.flake8) -- Décommenté pour Python
      try_add(diagnostics.pylint) -- Ajout pour une analyse plus complète
      try_add(diagnostics.mypy)   -- Analyse de type pour Python
      
      -- Web
      try_add(formatting.prettier)
      try_add(diagnostics.eslint)
      
      -- PHP
      try_add(diagnostics.phpcs)
      try_add(formatting.phpcsfixer)
      
      -- Ruby
      try_add(diagnostics.rubocop)
      try_add(formatting.rubocop)
      
      -- C#
      try_add(formatting.csharpier)
      
      -- Bash
      try_add(formatting.shfmt)
      try_add(diagnostics.shellcheck) -- Décommenté pour Bash
      
      -- Lua
      try_add(formatting.stylua)
      try_add(diagnostics.luacheck)
      
      -- Rust
      try_add(formatting.rustfmt)
      
      null_ls.setup({
        debug = true, -- Activez le débogage pour voir les erreurs potentielles
        sources = sources,
        on_attach = function(client, bufnr)
          -- Format on save (optionnel)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ 
                  bufnr = bufnr,
                  filter = function(c) 
                    return c.name == "null-ls" 
                  end
                })
              end,
            })
          end
          
          -- Notification lors de l'attachement
          local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
          print("None-LS attaché pour " .. filetype .. " avec " .. #sources .. " outils")
        end,
      })

      -- Configuration language-specific LSP
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            formatting = { enable = true },
          },
        },
      })
      
      -- Raccourci format
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format code" })
      -- Raccourci pour voir les diagnostics
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Afficher diagnostic" })
    end,
  },
}
