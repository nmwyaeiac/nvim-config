-- Intégration entre Mason et les outils de formatage/diagnostic
{
  "jay-babu/mason-null-ls.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    require("mason-null-ls").setup({
      -- Formatters et linters à installer automatiquement
      ensure_installed = {
        -- Formatters
        "black",         -- Python
        "prettier",      -- JS/TS/HTML/CSS
        "stylua",        -- Lua
        "clang-format",  -- C/C++
        "google-java-format", -- Java
        "phpcsfixer",    -- PHP
        "rubocop",       -- Ruby
        "csharpier",     -- C#
        "shfmt",         -- Bash
        "rustfmt",       -- Rust - Ajouter explicitement

        -- Linters
        "flake8",        -- Python
        "pylint",        -- Python
        "mypy",          -- Python
        "eslint_d",      -- JS/TS
        "shellcheck",    -- Bash
        -- "luacheck" retiré car problématique
        "cpplint",       -- C/C++
        "checkstyle",    -- Java
        "phpcs",         -- PHP
      },
      automatic_installation = true,
      handlers = {
        -- Configuration spéciale pour rustfmt
        rustfmt = function()
          -- Ne rien faire, car Mason ne peut pas installer rustfmt correctement
          -- Il est préférable de l'installer via rustup
        end,
      },
    })
  end,
}
