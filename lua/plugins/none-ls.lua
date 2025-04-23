return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local null_ls = require("null-ls")
      
      -- Sources de formatage et de diagnostic
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local code_actions = null_ls.builtins.code_actions
      local sources = {}

      -- Fonction helper améliorée pour tester si l'outil est installé
      local function is_available(cmd)
        return vim.fn.executable(cmd) == 1
      end

      -- Fonction pour ajouter une source seulement si elle est disponible
      local function add_if_available(source)
        if source then
          local cmd = source._opts and (source._opts.command or source._opts.cmd) or source.name
          if cmd and is_available(cmd) then
            table.insert(sources, source)
            return true
          end
        end
        return false
      end

      -- TypeScript/JavaScript
      if is_available("prettier") then
        table.insert(sources, formatting.prettier.with({
          filetypes = {
            "javascript", "typescript", "javascriptreact", "typescriptreact",
            "vue", "css", "scss", "html", "json", "yaml", "markdown", "graphql"
          }
        }))
      end
      
      if is_available("eslint") then
        -- Vérifier si eslint_d existe dans diagnostics
        if diagnostics.eslint then
          add_if_available(diagnostics.eslint)
        end
        
        -- Vérifier si eslint existe dans code_actions
        if code_actions.eslint then
          add_if_available(code_actions.eslint)
        end
      end

      -- Lua
      if is_available("stylua") then
        table.insert(sources, formatting.stylua.with({
          extra_args = {"--indent-type", "Spaces", "--indent-width", "2"}
        }))
      end

      -- Rust
      if is_available("rustfmt") then
        table.insert(sources, formatting.rustfmt.with({
          extra_args = {"--edition", "2021"}
        }))
      end

      -- C/C++
      add_if_available(formatting.clang_format)
      add_if_available(diagnostics.cpplint)

      -- Python
      add_if_available(formatting.black)
      add_if_available(diagnostics.flake8)
      add_if_available(diagnostics.mypy)

      -- PHP
      add_if_available(formatting.phpcsfixer)
      add_if_available(diagnostics.phpcs)

      -- Ruby
      add_if_available(formatting.rubocop)
      add_if_available(diagnostics.rubocop)

      -- C#
      add_if_available(formatting.csharpier)

      -- Shell/Bash
      add_if_available(formatting.shfmt)
      add_if_available(diagnostics.shellcheck)

      -- Java
      add_if_available(formatting.google_java_format)
      add_if_available(diagnostics.checkstyle)

      null_ls.setup({
        debug = false, -- Mettre à false en production
        sources = sources,
        on_attach = function(client, bufnr)
          -- Pas de format on save par défaut
        end,
      })

      -- Raccourci format
      vim.keymap.set("n", "<leader>gf", function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end, { desc = "Format code" })
      
      -- Raccourci pour voir les diagnostics
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Afficher diagnostic" })
    end,
  },
}
