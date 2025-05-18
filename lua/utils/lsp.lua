--- ### Utilitaires LSP.
local M = {}
local utils = require "utils"
local stored_handlers = {}

--- Appliquer les paramètres par défaut pour les diagnostics, le formatage et les capacités LSP.
M.apply_default_lsp_settings = function()
  -- Icônes
  local signs = {
    { name = "DiagnosticSignError",    text = "✖",        texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn",     text = "⚠",         texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignHint",     text = "➤",         texthl = "DiagnosticSignHint" },
    { name = "DiagnosticSignInfo",     text = "ℹ",         texthl = "DiagnosticSignInfo" },
    { name = "DapStopped",             text = "▶",             texthl = "DiagnosticWarn" },
    { name = "DapBreakpoint",          text = "●",          texthl = "DiagnosticInfo" },
    { name = "DapBreakpointRejected",  text = "○",  texthl = "DiagnosticError" },
    { name = "DapBreakpointCondition", text = "◆", texthl = "DiagnosticInfo" },
    { name = "DapLogPoint",            text = "◆",            texthl = "DiagnosticInfo" }
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  -- Appliquer les bordures arrondies LSP par défaut
  M.lsp_hover_config = vim.g.lsp_round_borders_enabled and { border = "rounded", silent = true } or {}

  -- Définir les diagnostics par défaut
  local default_diagnostics = {
    virtual_text = true,
    signs = true,
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

  -- Appliquer les diagnostics par défaut
  M.diagnostics = {
    -- diagnostics désactivés
    [0] = vim.tbl_deep_extend(
      "force",
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    -- statut seulement
    vim.tbl_deep_extend("force", default_diagnostics, { virtual_text = false, signs = false }),
    -- texte virtuel désactivé, signes activés
    vim.tbl_deep_extend("force", default_diagnostics, { virtual_text = false }),
    -- tous les diagnostics activés
    default_diagnostics,
  }
  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode or 3])

  -- Appliquer les paramètres de formatage
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

--- Cette fonction applique les mappages de touches LSP au LSP
function M.apply_user_lsp_mappings(client, bufnr)
  -- Utiliser les mappages LSP existants du client si disponible
  if require("keymaps.lsp") and require("keymaps.lsp").setup then
    require("keymaps.lsp").setup(client, bufnr)
  else
    -- Mappages LSP par défaut si keymaps.lsp n'est pas disponible
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    
    -- Diagnostic
    map("n", "<leader>ld", vim.diagnostic.open_float, "Hover diagnostics")
    map("n", "[d", function() vim.diagnostic.goto_prev() end, "Previous diagnostic")
    map("n", "]d", function() vim.diagnostic.goto_next() end, "Next diagnostic")
    map("n", "gl", vim.diagnostic.open_float, "Hover diagnostics")
    
    -- LSP actions
    map("n", "<leader>la", vim.lsp.buf.code_action, "LSP code action")
    map("v", "<leader>la", vim.lsp.buf.code_action, "LSP code action")
    map("n", "<leader>lf", function() vim.lsp.buf.format({async = true}) end, "Format buffer")
    map("n", "<leader>li", "<cmd>LspInfo<cr>", "LSP information")
    map("n", "<leader>lr", vim.lsp.buf.rename, "Rename current symbol")
    
    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map("n", "gr", vim.lsp.buf.references, "References of current symbol")
    map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map("n", "gt", vim.lsp.buf.type_definition, "Goto type definition")
    map("n", "gh", vim.lsp.buf.hover, "Hover help")
    map("n", "gH", vim.lsp.buf.signature_help, "Signature help")
  end
end

--- Spécifie des paramètres personnalisés pour les serveurs LSP
function M.apply_user_lsp_settings(server_name)
  local server = require("lspconfig")[server_name]

  -- Définir les capacités du serveur
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

  -- Définir les règles du serveur utilisateur.
  if server_name == "jsonls" then -- Ajouter les schémas schemastore
    local is_schemastore_loaded, schemastore = pcall(require, "schemastore")
    if is_schemastore_loaded then
      opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  if server_name == "yamlls" then -- Ajouter les schémas schemastore
    local is_schemastore_loaded, schemastore = pcall(require, "schemastore")
    if is_schemastore_loaded then opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
  end

  -- Les appliquer
  local old_on_attach = server.on_attach
  opts.on_attach = function(client, bufnr)
    if type(old_on_attach) == "function" then old_on_attach(client, bufnr) end
    M.apply_user_lsp_mappings(client, bufnr)
  end
  return opts
end

--- Cette fonction configure le serveur LSP
M.setup = function(server)
  -- Obtenir les paramètres utilisateur.
  local opts = M.apply_user_lsp_settings(server)

  -- Obtenir un gestionnaire de lspconfig.
  local setup_handler = stored_handlers[server] or require("lspconfig")[server].setup(opts)

  -- Appliquer nos paramètres utilisateur au gestionnaire lspconfig.
  if setup_handler then setup_handler(server, opts) end
end
-- Modification à la fonction setup dans utils/lsp.lua
M.setup = function(server)
  -- Ignorer certains serveurs qui sont gérés spécialement
  if server == "jdtls" then
    -- JDTLS est géré par nvim-java, on ignore donc sa configuration ici
    return
  end

  -- Obtenir les paramètres utilisateur.
  local opts = M.apply_user_lsp_settings(server)

  -- Configurer le serveur LSP
  require("lspconfig")[server].setup(opts)
end
return M
