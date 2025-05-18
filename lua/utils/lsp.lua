--- ### Utilitaires LSP.

--  DESCRIPTION:
--  Fonctions utilisées pour configurer le plugin `mason-lspconfig.nvim`.
--  Vous pouvez spécifier vos propres paramètres lsp dans `M.apply_user_lsp_settings()`.

local M = {}
local utils = require "base.utils"
local stored_handlers = {}

--- Appliquer les paramètres par défaut pour les diagnostics, le formatage et les capacités LSP.
--- Doit être exécuté une seule fois, normalement sur mason-lspconfig.
--- @return nil
M.apply_default_lsp_settings = function()
  -- Icônes
  local get_icon = utils.get_icon
  local signs = {
    { name = "DiagnosticSignError",    text = get_icon("DiagnosticError"),        texthl = "DiagnosticSignError" },
    { name = "DiagnosticSignWarn",     text = get_icon("DiagnosticWarn"),         texthl = "DiagnosticSignWarn" },
    { name = "DiagnosticSignHint",     text = get_icon("DiagnosticHint"),         texthl = "DiagnosticSignHint" },
    { name = "DiagnosticSignInfo",     text = get_icon("DiagnosticInfo"),         texthl = "DiagnosticSignInfo" },
    { name = "DapStopped",             text = get_icon("DapStopped"),             texthl = "DiagnosticWarn" },
    { name = "DapBreakpoint",          text = get_icon("DapBreakpoint"),          texthl = "DiagnosticInfo" },
    { name = "DapBreakpointRejected",  text = get_icon("DapBreakpointRejected"),  texthl = "DiagnosticError" },
    { name = "DapBreakpointCondition", text = get_icon("DapBreakpointCondition"), texthl = "DiagnosticInfo" },
    { name = "DapLogPoint",            text = get_icon("DapLogPoint"),            texthl = "DiagnosticInfo" }
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  -- Appliquer les bordures arrondies LSP par défaut
  M.lsp_hover_config = vim.g.lsp_round_borders_enabled and { border = "rounded", silent = true } or {}

  -- Définir les diagnostics par défaut
  local default_diagnostics = {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = utils.get_icon("DiagnosticError"),
        [vim.diagnostic.severity.HINT] = utils.get_icon("DiagnosticHint"),
        [vim.diagnostic.severity.WARN] = utils.get_icon("DiagnosticWarn"),
        [vim.diagnostic.severity.INFO] = utils.get_icon("DiagnosticInfo"),
      },
      active = signs,
    },
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
  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode])

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

--- Cette fonction a pour seul but de transmettre les mappages de touches LSP au LSP.
--- @param client string Le client pour lequel les mappages seront chargés.
--- @param bufnr string Le buffer pour lequel les mappages seront chargés.
function M.apply_user_lsp_mappings(client, bufnr)
  local lsp_mappings = require("base.4-mappings").lsp_mappings(client, bufnr)
  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v["<leader>l"] = { desc = utils.get_icon("ActiveLSP", 1, true) .. "LSP" }
  end
  utils.set_mappings(lsp_mappings, { buffer = bufnr })
end

--- Vous pouvez spécifier ici des paramètres personnalisés pour les serveurs LSP.
--- @param server_name string Le nom du serveur
--- @return table # La table d'options LSP utilisée lors de la configuration du serveur de langage
function M.apply_user_lsp_settings(server_name)
  local server = require("lspconfig")[server_name]

  -- Définir les capacités du serveur utilisateur.
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

--- Cette fonction transmet les `paramètres lsp de l'utilisateur` à lspconfig,
--- qui est responsable de tout configurer pour nous.
--- @param server string Un nom de serveur lsp.
--- @return nil
M.setup = function(server)
  -- Obtenir les paramètres utilisateur.
  local opts = M.apply_user_lsp_settings(server)

  -- Obtenir un gestionnaire de lspconfig.
  local setup_handler = stored_handlers[server] or require("lspconfig")[server].setup(opts)

  -- Appliquer nos paramètres utilisateur au gestionnaire lspconfig.
  if setup_handler then setup_handler(server, opts) end
end

return M
