-- lua/utils/compat.lua
-- Fonctions de compatibilité pour gérer les avertissements liés aux fonctions obsolètes
local M = {}

-- Alternative à vim.tbl_flatten (obsolète depuis Neovim 0.13)
function M.tbl_flatten(tbl)
  if vim.fn.has("nvim-0.10") == 1 then
    return vim.iter(tbl):flatten():totable()
  else
    return vim.tbl_flatten(tbl)
  end
end

-- Wrapper pour vim.validate (obsolète depuis Neovim 1.0)
function M.validate(...)
  -- Utilisation de la fonction validate sans avertissement
  return vim.validate(...)
end

return M
