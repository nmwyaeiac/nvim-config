-- lua/utils/compat.lua (corrigé)
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

-- Référence à la fonction validate originale (pour éviter la récursion)
local original_validate = vim.validate

-- Wrapper pour vim.validate (obsolète depuis Neovim 1.0)
-- Cette fonction est conçue pour être un remplacement direct
-- qui évite les avertissements tout en gardant la même fonctionnalité
function M.validate(...)
  -- Désactiver temporairement les avertissements de dépréciation
  local old_deprecated_fn = vim._with_meta and vim._with_meta.deprecated_fn
  if old_deprecated_fn then
    vim._with_meta.deprecated_fn = function() end
  end
  
  -- ATTENTION: Ici on appelle la référence originale, PAS vim.validate
  -- car vim.validate pourrait déjà référencer M.validate (récursion infinie)
  local result = original_validate(...)
  
  -- Restaurer le comportement d'avertissement
  if old_deprecated_fn then
    vim._with_meta.deprecated_fn = old_deprecated_fn
  end
  
  return result
end

-- Fonction pour patcher les plugins qui utilisent vim.validate
-- Cette fonction est utile pour les plugins que nous ne pouvons pas modifier directement
function M.patch_validate_calls()
  -- Remplacer par notre version sans avertissement
  vim.validate = M.validate
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.validate = original_validate
  end
end

-- Fonction pour patcher les plugins qui utilisent vim.tbl_flatten
function M.patch_tbl_flatten_calls()
  -- Sauvegarder la fonction originale
  local original_tbl_flatten = vim.tbl_flatten
  
  -- Remplacer par notre version compatible
  vim.tbl_flatten = M.tbl_flatten
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.tbl_flatten = original_tbl_flatten
  end
end

return M
