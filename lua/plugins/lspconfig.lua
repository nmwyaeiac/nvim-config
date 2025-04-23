return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim", -- Aide pour la configuration Lua
    },
    config = function()
      -- Configuration pour la documentation Lua/Neovim
      require("neodev").setup()

      -- Import des modules nécessaires
      local lspconfig = require("lspconfig")
      local lsp_keymaps = require("keymaps.lsp")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configuration des icônes pour les diagnostics
      local signs = {
        { name = "DiagnosticSignError", text = "✘" },
        { name = "DiagnosticSignWarn", text = "▲" },
        { name = "DiagnosticSignHint", text = "⚑" },
        { name = "DiagnosticSignInfo", text = "ℹ" },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
      end

      -- Configuration globale des diagnostics
      vim.diagnostic.config({
        virtual_text = true,
        signs = { active = signs },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Configuration fenêtres flottantes
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      -- Fonction d'attachement LSP commune avec keymaps
      local function on_attach(client, bufnr)
        -- Configurer les raccourcis clavier
        lsp_keymaps.setup(client, bufnr)

        -- Désactiver le formatage pour certains serveurs (si on utilise none-ls à la place)
        if client.name == "typescript" or client.name == "clangd" or
           client.name == "lua_ls" or client.name == "rust_analyzer" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end

        -- Ajouter un highlight pour les références sous le curseur
        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
          vim.api.nvim_create_autocmd("CursorHold", {
            group = "lsp_document_highlight",
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            group = "lsp_document_highlight",
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- TypeScript
      lspconfig.typescript.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            format = {
              enable = false, -- Désactiver le formatage intégré
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            format = {
              enable = false, -- Désactiver le formatage intégré
            },
          },
        },
      })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Reconnaître vim comme global pour les configs Neovim
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
            completion = {
              callSnippet = "Replace",
            },
            format = {
              enable = false, -- Désactiver le formatage intégré
            }
          },
        },
      })

      -- Rust
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            cargo = {
              allFeatures = true,
            },
            inlayHints = {
              typeHints = {
                enable = true,
              },
              parameterHints = {
                enable = true,
              },
            },
            -- Désactiver le formatage intégré
            rustfmt = {
              rangeFormatting = {
                enable = false,
              },
            },
          },
        },
      })

      -- Autres serveurs LSP déjà dans votre configuration...
      -- C/C++, Python, etc.

      -- Auto-configuration pour les autres serveurs LSP installés avec Mason
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          -- Configuration par défaut pour les serveurs LSP non explicitement définis
          if not (
            server_name == "typescript" or
            server_name == "lua_ls" or
            server_name == "rust_analyzer"
            -- Ajoutez ici les autres serveurs que vous avez déjà définis explicitement
          ) then
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end
        end,
      })
    end,
  },
}
