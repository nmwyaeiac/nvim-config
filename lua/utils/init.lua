-- Utilitaires généraux
local M = {}

-- Vérifie si un plugin est disponible
function M.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

-- Définir des mappings
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

-- Envoyer une notification
function M.notify(msg, type, opts)
  vim.schedule(function()
    vim.notify(
      msg, type, vim.tbl_deep_extend("force", { title = "Neovim" }, opts or {})
    )
  end)
end

return M
