-- lua/utils/compat.lua (version corrigée)
-- Fonctions de compatibilité pour gérer les avertissements liés aux fonctions obsolètes

-- Table pour stocker nos fonctions
local M = {}

-- Stockage des références originales
local _original_validate = nil
local _original_tbl_flatten = nil

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
  -- Utiliser la référence originale pour éviter la récursion
  return _original_validate(...)
end

-- Fonction pour patcher les plugins qui utilisent vim.validate
function M.patch_validate_calls()
  -- Enregistrer la fonction originale (IMPORTANT: avant de patcher)
  if _original_validate == nil then
    _original_validate = vim.validate
  end
  
  -- Vérifier si déjà patché pour éviter la récursion
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
  -- Enregistrer la fonction originale (IMPORTANT: avant de patcher)
  if _original_tbl_flatten == nil then
    _original_tbl_flatten = vim.tbl_flatten
  end
  
  -- Vérifier si déjà patché pour éviter la récursion
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
