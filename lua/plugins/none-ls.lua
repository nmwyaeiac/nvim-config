return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig", -- Ajout de lspconfig ici
    },
    config = function()
      local null_ls = require("null-ls")
      local lspconfig = require("lspconfig") -- OK maintenant

      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local sources = {}

      -- Helper pour ajouter un outil seulement s'il est installé
      local function with_exe(builtin)
        if builtin and vim.fn.executable(builtin._opts.command or builtin._opts.cmd or builtin.name) == 1 then
          return builtin
        end
        return nil
      end

      -- C/C++
      table.insert(sources, with_exe(formatting.clang_format))
      table.insert(sources, with_exe(diagnostics.clang_check))

      -- Java
      table.insert(sources, with_exe(formatting.google_java_format))

      -- Python
      table.insert(sources, with_exe(formatting.black))
      -- table.insert(sources, with_exe(diagnostics.flake8))

      -- HTML/CSS/JS/TS
      table.insert(sources, with_exe(formatting.prettier))

      -- PHP
      table.insert(sources, with_exe(diagnostics.phpcs))
      table.insert(sources, with_exe(formatting.phpcsfixer))

      -- Ruby
      table.insert(sources, with_exe(diagnostics.rubocop))
      table.insert(sources, with_exe(formatting.rubocop))

      -- C#
      table.insert(sources, with_exe(formatting.csharpier))

      -- Bash
      table.insert(sources, with_exe(formatting.shfmt))
      -- table.insert(sources, with_exe(diagnostics.shellcheck))

      -- Lua
      table.insert(sources, with_exe(formatting.stylua))

      null_ls.setup({
        sources = vim.tbl_filter(function(item)
          return item ~= nil
        end, sources),
        on_attach = function(client, bufnr)
          -- Optionnel : actions lors de l'attachement du LSP
        end,
      })

      -- rust-analyzer config (ne fonctionne que si lspconfig est bien installé)
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            formatting = {
              enable = true,
            },
          },
        },
      })

      -- Raccourci format
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
  },
}
