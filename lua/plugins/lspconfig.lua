-- Configuration des plugins LSP et outils de développement
return {
  -- nvim-lspconfig : Configurations des serveurs LSP
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "folke/neodev.nvim", -- Aide pour la configuration de Lua/Neovim
    },
  },

  -- Mason : Gestionnaire de paquets pour les outils LSP, DAP, linters et formatters
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
      "MasonUpdateAll",
    },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      },
      ensure_installed = true,
      log_level = vim.log.levels.INFO,
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- mason-lspconfig : Intégration entre Mason et LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {"williamboman/mason.nvim", "neovim/nvim-lspconfig"},
    event = "BufReadPre",
    opts = {
      ensure_installed = {
        -- Serveurs LSP à installer automatiquement
        "clangd",        -- C/C++
        "pyright",       -- Python
        "tsserver",      -- TypeScript/JavaScript
        "cssls",         -- CSS
        "html",          -- HTML
        "eslint",        -- ESLint
        "rust_analyzer", -- Rust
        "lua_ls",        -- Lua
        "jsonls",        -- JSON
        "yamlls",        -- YAML
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      local utils_lsp = require("utils.lsp")
      require("mason-lspconfig").setup(opts)
      
      -- Appliquer les réglages LSP par défaut
      utils_lsp.apply_default_lsp_settings()
      
      -- Configurer les gestionnaires pour chaque serveur LSP
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          utils_lsp.setup(server_name)
        end,
      })
    end,
  },

  -- none-ls : Pour le formatage de code et les linters
  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPre",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = function()
      local utils_lsp = require("utils.lsp")
      return {
        on_attach = utils_lsp.apply_user_lsp_mappings
      }
    end,
  },

  -- SchemaStore : Schémas JSON supplémentaires
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },

  -- Autocomplétion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
          }),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },

  -- LuaSnip : Moteur de snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- lsp_signature : Aide pour les signatures de fonctions
  {
    "ray-x/lsp_signature.nvim",
    event = "BufReadPre",
    opts = {
      floating_window = true,
      hint_enable = false,
      handler_opts = {
        border = "rounded"
      },
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },

  -- Indication visuelle pour les actions de code
  {
    "kosayoda/nvim-lightbulb",
    event = "BufReadPre",
    opts = {
      sign = { enabled = true, priority = 10 },
      virtual_text = { enabled = false },
      autocmd = { enabled = true },
    },
  },
}
