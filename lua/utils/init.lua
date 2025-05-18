--- ### Utilitaires généraux.

--  DESCRIPTION:
--  Fonctions utilitaires générales à utiliser dans Nvim.

local M = {}

-- Fonction simplifiée pour get_icon - adaptez selon votre configuration
function M.get_icon(icon_name, fallback_to_empty_string)
  -- Si vous n'utilisez pas le système d'icônes de NormalNvim,
  -- vous pouvez simplement retourner des valeurs par défaut
  local icons = {
    -- Ajoutez ici des icônes selon vos besoins, par exemple:
    DiagnosticError = "✖",
    DiagnosticWarn = "⚠",
    DiagnosticHint = "➤",
    DiagnosticInfo = "ℹ",
    DapStopped = "▶",
    DapBreakpoint = "●",
    DapBreakpointRejected = "○",
    DapBreakpointCondition = "◆",
    DapLogPoint = "◆",
    ActiveLSP = "󰘧",
  }
  
  return icons[icon_name] or ""
end

-- Fonction simplifiée pour is_available (vérifier si un plugin est disponible)
function M.is_available(plugin)
  local ok, lazy_config = pcall(require, "lazy.core.config")
  return ok and lazy_config.spec.plugins[plugin] ~= nil
end

-- Déclenche un événement personnalisé
function M.trigger_event(event, is_urgent)
  local function trigger()
    local is_user_event = string.match(event, "^User ") ~= nil
    if is_user_event then
      event = event:gsub("^User ", "")
      vim.api.nvim_exec_autocmds("User", { pattern = event, modeline = false })
    else
      vim.api.nvim_exec_autocmds(event, { modeline = false })
    end
  end

  if is_urgent then
    trigger()
  else
    vim.schedule(trigger)
  end
end

-- Fonction simplifiée pour définir des mappages
function M.set_mappings(map_table, base)
  for mode, maps in pairs(map_table) do
    for keymap, options in pairs(maps) do
      if options then
        local cmd
        local keymap_opts = base or {}
        if type(options) == "string" or type(options) == "function" then
          cmd = options
        else
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend("force", keymap_opts, options)
          keymap_opts[1] = nil
        end
        
        if cmd then
          vim.keymap.set(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
end

return M
