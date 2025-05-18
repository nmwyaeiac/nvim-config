-- lua/utils/compat.lua (version corrigée)
-- Fonctions de compatibilité pour gérer les avertissements liés aux fonctions obsolètes

-- Table pour stocker nos fonctions
local M = {}

-- IMPORTANT: Sauvegarder les références originales en dehors de toute fonction
-- pour éviter les problèmes de récursion
local _original_validate = vim.validate
local _original_tbl_flatten = vim.tbl_flatten

-- Alternative à vim.tbl_flatten (obsolète depuis Neovim 0.13)
function M.tbl_flatten(tbl)
  if vim.fn.has("nvim-0.10") == 1 then
    return vim.iter(tbl):flatten():totable()
  else
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
  
  -- Utiliser la référence originale pour éviter la récursion
  local result = _original_validate(...)
  
  -- Restaurer le comportement d'avertissement
  if old_deprecated_fn then
    vim._with_meta.deprecated_fn = old_deprecated_fn
  end
  
  return result
end

-- Fonction pour patcher les plugins qui utilisent vim.validate
function M.patch_validate_calls()
  -- Important: vérifier si vim.validate a déjà été patché pour éviter la récursion
  if vim.validate == M.safe_validate then
    return function() end -- Retourner une fonction vide si déjà patché
  end
  
  -- Remplacer vim.validate par notre version sans avertissement
  vim.validate = M.safe_validate
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.validate = _original_validate
  end
end

-- Fonction pour patcher les plugins qui utilisent vim.tbl_flatten
function M.patch_tbl_flatten_calls()
  -- Important: vérifier si vim.tbl_flatten a déjà été patché pour éviter la récursion
  if vim.tbl_flatten == M.tbl_flatten then
    return function() end -- Retourner une fonction vide si déjà patché
  end
  
  -- Remplacer par notre version compatible
  vim.tbl_flatten = M.tbl_flatten
  
  -- Retourner une fonction pour restaurer l'original si nécessaire
  return function()
    vim.tbl_flatten = _original_tbl_flatten
  end
end

-- Fonction pour appliquer tous les patches de compatibilité en une seule fois
function M.apply_compatibility_patches()
  local restore_validate = M.patch_validate_calls()
  local restore_tbl_flatten = M.patch_tbl_flatten_calls()
  
  -- Retourner une fonction pour restaurer toutes les fonctions originales
  return function()
    restore_validate()
    restore_tbl_flatten()
  end
end

return M
