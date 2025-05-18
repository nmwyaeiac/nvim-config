-- Utilitaires pour la configuration LSP
local M = {}
local utils = require("utils")
local stored_handlers = {}

-- Appliquer les paramètres par défaut pour les diagnostics, le formatage et les capacités LSP
function M.apply_default_lsp_settings()
  -- Icônes pour les diagnostics
  local signs = {
    { name = "DiagnosticSignError", text = "✘", texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn", text = "▲", texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignHint", text = "⚑", texthl = "DiagnosticSignHint" },
    { name = "DiagnosticSignInfo", text = "ℹ", texthl = "DiagnosticSignInfo" },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  -- Configuration hover LSP avec bordures arrondies
  M.lsp_hover_config = { border = "rounded", silent = true }

  -- Configuration par défaut des diagnostics
  local default_diagnostics = {
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  -- Modes de diagnostic (0 à 3, du moins au plus verbeux)
  M.diagnostics = {
    [0] = vim.tbl_deep_extend(
      "force",
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    vim.tbl_deep_extend("force", default_diagnostics, { virtual_text = false, signs = false }),
    vim.tbl_deep_extend("force", default_diagnostics, { virtual_text = false }),
    default_diagnostics,
  }
  vim.diagnostic.config(M.diagnostics[3]) -- Mode par défaut

  -- Configuration du formatage
  M.formatting = { format_on_save = { enabled = true }, disabled = {} }
  if type(M.formatting.format_on_save) == "boolean" then
    M.formatting.format_on_save = { enabled = M.formatting.format_on_save }
  end
  M.format_opts = vim.deepcopy(M.formatting)
  M.format_opts.disabled = nil
  M.format_opts.format_on_save = nil
  M.format_opts.filter = function(client)
    local filter = M.formatting.filter
    local disabled = M.formatting.disabled or {}
    return not (vim.tbl_contains(disabled, client.name) or (type(filter) == "function" and not filter(client)))
  end
end

-- Appliquer les raccourcis clavier LSP
function M.apply_user_lsp_mappings(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Navigation de code
  map("n", "gd", vim.lsp.buf.definition, "Aller à la définition")
  map("n", "gr", vim.lsp.buf.references, "Trouver les références")
  map("n", "gi", vim.lsp.buf.implementation, "Aller à l'implémentation")
  map("n", "gD", vim.lsp.buf.declaration, "Aller à la déclaration")
  map("n", "gt", vim.lsp.buf.type_definition, "Aller à la définition du type")

  -- Affichage d'informations
  map("n", "K", vim.lsp.buf.hover, "Afficher la documentation")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Afficher l'aide de signature")

  -- Refactoring et actions de code
  map("n", "<leader>rn", vim.lsp.buf.rename, "Renommer")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Actions de code")
  map("n", "<leader>gf", function() vim.lsp.buf.format(M.format_opts) end, "Formater le code")

  -- Diagnostic
  map("n", "[d", vim.diagnostic.goto_prev, "Diagnostic précédent")
  map("n", "]d", vim.diagnostic.goto_next, "Diagnostic suivant")
  map("n", "<leader>dl", vim.diagnostic.open_float, "Afficher le diagnostic sous le curseur")
  map("n", "<leader>dq", vim.diagnostic.setloclist, "Liste des diagnostics")

  -- Mise en surbrillance des références
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

  -- Format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
      buffer = bufnr,
      callback = function()
        if M.formatting.format_on_save.enabled then
          vim.lsp.buf.format(vim.tbl_deep_extend("force", M.format_opts, { bufnr = bufnr }))
        end
      end,
    })
  end
end

-- Appliquer les paramètres personnalisés pour les serveurs LSP
function M.apply_user_lsp_settings(server_name)
  local server = require("lspconfig")[server_name]

  -- Définir les capacités du client
  M.capabilities = vim.lsp.protocol.make_client_capabilities()
  M.capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
  M.capabilities.textDocument.completion.completionItem.snippetSupport = true
  M.capabilities.textDocument.completion.completionItem.preselectSupport = true
  M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  M.capabilities.textDocument.completion.completionItem.resolveSupport =
  { properties = { "documentation", "detail", "additionalTextEdits" } }
  M.capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
  
  M.flags = {}
  local opts = vim.tbl_deep_extend("force", server, { capabilities = M.capabilities, flags = M.flags })

  -- Configurations spécifiques pour certains serveurs
  if server_name == "jsonls" then
    local is_schemastore_loaded, schemastore = pcall(require, "schemastore")
    if is_schemastore_loaded then
      opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  
  if server_name == "yamlls" then
    local is_schemastore_loaded, schemastore = pcall(require, "schemastore")
    if is_schemastore_loaded then
      opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } }
    end
  end

  if server_name == "lua_ls" then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" }, -- Reconnaître vim comme global pour Neovim
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
      },
    }
  end

  -- Appliquer les paramètres
  local old_on_attach = server.on_attach
  opts.on_attach = function(client, bufnr)
    if type(old_on_attach) == "function" then old_on_attach(client, bufnr) end
    M.apply_user_lsp_mappings(client, bufnr)
  end
  
  return opts
end

-- Configurer le serveur LSP
function M.setup(server)
  local opts = M.apply_user_lsp_settings(server)
  local setup_handler = stored_handlers[server] or require("lspconfig")[server].setup(opts)
  if setup_handler then setup_handler(server, opts) end
end

return M
