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

      -- Fonction de sécurité pour vérifier l'existence d'une source avant de l'utiliser
      local function safe_add(category, name)
        if category and category[name] then
          return add_if_available(category[name])
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
        safe_add(diagnostics, "eslint")
        
        -- Vérifier si eslint existe dans code_actions
        safe_add(code_actions, "eslint")
      end

      -- Lua
      if is_available("stylua") then
        table.insert(sources, formatting.stylua.with({
          extra_args = {"--indent-type", "Spaces", "--indent-width", "2"}
        }))
      end

      -- Rust
      if is_available("rustfmt") and formatting.rustfmt then
        table.insert(sources, formatting.rustfmt.with({
          extra_args = {"--edition", "2021"}
        }))
      end

      -- C/C++
      safe_add(formatting, "clang_format")
      safe_add(diagnostics, "cpplint")

      -- Python
      safe_add(formatting, "black")
      safe_add(diagnostics, "flake8")
      safe_add(diagnostics, "mypy")

      -- PHP
      safe_add(formatting, "phpcsfixer")
      safe_add(diagnostics, "phpcs")

      -- Ruby
      safe_add(formatting, "rubocop")
      safe_add(diagnostics, "rubocop")

      -- C#
      safe_add(formatting, "csharpier")

      -- Shell/Bash
      safe_add(formatting, "shfmt")
      -- Vérifier si shellcheck est disponible sous différents noms possibles
      if not safe_add(diagnostics, "shellcheck") then
        -- Essayer des alternatives si elles existent
        safe_add(diagnostics, "sh")
        -- Ou l'ajouter manuellement si vous connaissez la commande exacte
        if is_available("shellcheck") then
          -- Cette partie est optionnelle et dépend de l'API actuelle de none-ls
          -- Si vous connaissez la structure correcte pour shellcheck
          local shellcheck_source = null_ls.register({
            name = "shellcheck",
            method = null_ls.methods.DIAGNOSTICS,
            filetypes = { "sh", "bash" },
            command = "shellcheck",
            args = { "--format=json", "--severity=style", "--shell=bash", "--external-sources", "-" },
            -- Ajoutez d'autres options nécessaires
          })
          if shellcheck_source then
            table.insert(sources, shellcheck_source)
          end
        end
      end

      -- Java
      safe_add(formatting, "google_java_format")
      safe_add(diagnostics, "checkstyle")

      null_ls.setup({
        debug = true, -- Temporairement mettre à true pour voir les erreurs détaillées
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
