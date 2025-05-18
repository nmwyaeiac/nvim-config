-- lua/plugins/null-ls-fixed.lua
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

      -- Fonction sécurisée pour vérifier si une commande est disponible
      local function is_executable(name)
        return vim.fn.executable(name) == 1
      end

      -- Fonction sécurisée pour ajouter une source si elle existe
      local function safe_add(source_table, source_name, cmd_name, opts)
        cmd_name = cmd_name or source_name
        if source_table and source_table[source_name] and is_executable(cmd_name) then
          if opts then
            table.insert(sources, source_table[source_name].with(opts))
          else
            table.insert(sources, source_table[source_name])
          end
          return true
        end
        return false
      end

      -- TypeScript/JavaScript
      safe_add(formatting, "prettier", "prettier", {
        filetypes = {
          "javascript", "typescript", "javascriptreact", "typescriptreact",
          "vue", "css", "scss", "html", "json", "yaml", "markdown", "graphql"
        }
      })
      
      -- ESLint (diagnostics et code actions)
      safe_add(diagnostics, "eslint", "eslint")
      safe_add(code_actions, "eslint", "eslint")

      -- Lua
      safe_add(formatting, "stylua", "stylua", {
        extra_args = {"--indent-type", "Spaces", "--indent-width", "2"}
      })

      -- Rust
      safe_add(formatting, "rustfmt", "rustfmt", {
        extra_args = {"--edition", "2021"}
      })

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
      -- Vérifier les différentes versions du binaire csharpier
      if is_executable("dotnet-csharpier") then
        safe_add(formatting, "csharpier", "dotnet-csharpier")
      elseif is_executable("csharpier") then
        safe_add(formatting, "csharpier", "csharpier")
      else
        vim.notify("C# formatter (csharpier) n'est pas installé. Consultez https://csharpier.com/ pour l'installation", vim.log.levels.WARN)
      end

      -- Shell/Bash
      safe_add(formatting, "shfmt", "shfmt")
      safe_add(diagnostics, "shellcheck", "shellcheck")

      -- Java
      safe_add(formatting, "google_java_format", "google-java-format")
      safe_add(diagnostics, "checkstyle", "checkstyle")

      null_ls.setup({
        debug = false,
        sources = sources,
        on_attach = function(client, bufnr)
          -- Format on save optionnel
          -- vim.api.nvim_buf_create_user_command(bufnr, "Format", function() vim.lsp.buf.format() end, {})
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
