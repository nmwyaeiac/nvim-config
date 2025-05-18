-- lua/utils/compat.lua (version corrigée)
-- Fonctions de compatibilité pour gérer les avertissements liés aux fonctions obsolètes

-- IMPORTANT: Sauvegarder les références originales AVANT toute autre définition
-- pour éviter les problèmes de récursion
local _original_validate = vim.validate
local _original_tbl_flatten = vim.tbl_flatten

local M = {}

-- Alternative à vim.tbl_flatten (obsolète depuis Neovim 0.13)
function M.tbl_flatten(tbl)
  if vim.fn.has("nvim-0.10") == 1 then
    return vim.iter(tbl):flatten():totable()
  else
    -- Utiliser la référence sauvegardée, pas vim.tbl_flatten directement
    return _original_tbl_flatten(tbl)
  end
end

-- Wrapper pour vim.validate qui supprime les avertissements (obsolète depuis Neovim 1.0)
function M.safe_validate(...)
  -- Désactiver temporairement les avertissements de dépréciation
  local old_deprecated_fn = vim._with_meta and vim._with_meta.deprecated_fn
  if old_deprecated_fn then
    vim._with_meta.deprecated_fn = function() end
  end
  
  -- IMPORTANT: Utiliser la référence sauvegardée, jamais vim.validate directement
  -- pour éviter la récursion infinie
  local result = _original_validate(...)
  
  -- Restaurer le comportement d'avertissement
  if old_deprecated_fn then
    vim._with_meta.deprecated_fn = old_deprecated_fn
  end
  
  return result
end

-- Fonction pour patcher les plugins qui utilisent vim.validate
function M.patch_validate_calls()
  -- Remplacer par notre version sans avertissement
  vim.validate = M.safe_validate
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.validate = _original_validate
  end
end

-- Fonction pour patcher les plugins qui utilisent vim.tbl_flatten
function M.patch_tbl_flatten_calls()
  -- Remplacer par notre version compatible
  vim.tbl_flatten = M.tbl_flatten
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.tbl_flatten = _original_tbl_flatten
  end
end

-- Fonction pour appliquer tous les patches de compatibilité en une seule fois
function M.apply_compatibility_patches()
  M.patch_validate_calls()
  M.patch_tbl_flatten_calls()
  
  -- Retourne une fonction pour restaurer toutes les fonctions originales
  return function()
    vim.validate = _original_validate
    vim.tbl_flatten = _original_tbl_flatten
  end
end

return M
