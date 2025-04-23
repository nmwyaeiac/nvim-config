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

      -- Imprimer les noms des sources disponibles pour le débogage
      local function print_available_sources()
        print("Formatters disponibles:")
        for name, _ in pairs(null_ls.builtins.formatting) do
          print("- " .. name)
        end

        print("\nDiagnostics disponibles:")
        for name, _ in pairs(null_ls.builtins.diagnostics) do
          print("- " .. name)
        end
        
        print("\nCode actions disponibles:")
        for name, _ in pairs(null_ls.builtins.code_actions) do
          print("- " .. name)
        end
      end
      
      -- Décommenter cette ligne pour déboguer
      -- print_available_sources()

      -- Fonction helper améliorée pour tester si l'outil est installé
      local function is_available(cmd)
        return vim.fn.executable(cmd) == 1
      end

      -- Fonction sécurisée pour ajouter une source si elle existe
      local function safe_add(source_table, source_name, cmd_name)
        cmd_name = cmd_name or source_name
        if source_table and source_table[source_name] and is_available(cmd_name) then
          table.insert(sources, source_table[source_name])
          return true
        end
        return false
      end

      -- TypeScript/JavaScript
      if is_available("prettier") and formatting.prettier then
        table.insert(sources, formatting.prettier.with({
          filetypes = {
            "javascript", "typescript", "javascriptreact", "typescriptreact",
            "vue", "css", "scss", "html", "json", "yaml", "markdown", "graphql"
          }
        }))
      end
      
      -- ESLint (diagnostics et code actions)
      safe_add(diagnostics, "eslint", "eslint")
      safe_add(code_actions, "eslint", "eslint")

      -- Lua
      if is_available("stylua") and formatting.stylua then
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
      safe_add(formatting, "clang_format", "clang-format")
      safe_add(diagnostics, "cpplint", "cpplint")

      -- Python
      safe_add(formatting, "black", "black")
      safe_add(diagnostics, "flake8", "flake8")
      safe_add(diagnostics, "mypy", "mypy")

      -- PHP
      safe_add(formatting, "phpcsfixer", "php-cs-fixer")
      safe_add(diagnostics, "phpcs", "phpcs")

      -- Ruby
      safe_add(formatting, "rubocop", "rubocop")
      safe_add(diagnostics, "rubocop", "rubocop")

      -- C#
      safe_add(formatting, "csharpier", "dotnet-csharpier")

      -- Shell/Bash
      safe_add(formatting, "shfmt", "shfmt")
      
      -- Vérifier les différents noms possibles pour shellcheck
      if not safe_add(diagnostics, "shellcheck", "shellcheck") then
        safe_add(diagnostics, "sh", "sh")
      end

      -- Java
      safe_add(formatting, "google_java_format", "google-java-format")
      safe_add(diagnostics, "checkstyle", "checkstyle")

      null_ls.setup({
        debug = false,
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
