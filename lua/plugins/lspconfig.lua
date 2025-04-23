-- Partie à modifier dans votre lspconfig.lua
-- Remplacez les sections correspondantes dans votre fichier

-- TypeScript
lspconfig.typescript.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Appliquer les raccourcis standard
    lsp_keymaps.setup(client, bufnr)
    
    -- Désactiver le formatage intégré pour utiliser null-ls à la place
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Conserver les autres fonctionnalités
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
  end,
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
  on_attach = function(client, bufnr)
    -- Raccourcis standards
    lsp_keymaps.setup(client, bufnr)
    
    -- Désactiver le formatage intégré pour utiliser stylua via null-ls
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Conserver les highlights
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
  end,
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
  on_attach = function(client, bufnr)
    -- Raccourcis standards
    lsp_keymaps.setup(client, bufnr)
    
    -- Désactiver le formatage intégré pour utiliser rustfmt via null-ls
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Conserver les autres fonctionnalités
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
  end,
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
        enableExperimental = false,
        rangeFormatting = {
          enable = false,
        },
      },
    },
  },
})
