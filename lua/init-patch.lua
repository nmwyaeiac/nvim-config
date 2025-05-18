-- lua/init-patch.lua (corrigé)
-- Ce fichier contient une fonction à appeler au démarrage pour corriger
-- les avertissements liés aux fonctions obsolètes

local M = {}

function M.apply_compatibility_patches()
  -- Charger notre module de compatibilité amélioré
  -- Correction du nom du module pour correspondre au fichier existant
  local compat = require("utils.compat")
  
  -- Appliquer les patches pour les fonctions obsolètes
  compat.patch_validate_calls()
  compat.patch_tbl_flatten_calls()
  
  -- Informer l'utilisateur (optionnel)
  vim.notify("Patches de compatibilité appliqués pour supprimer les avertissements", vim.log.levels.INFO, {
    title = "Neovim Compatibility",
    timeout = 3000
  })
end

-- Fonction pour vérifier les dépendances manquantes
function M.check_missing_dependencies()
  local missing = {}
  
  -- Vérifier dotnet-csharpier / csharpier
  if vim.fn.executable("dotnet-csharpier") == 0 and vim.fn.executable("csharpier") == 0 then
    table.insert(missing, {
      name = "dotnet-csharpier",
      message = "Formateur C# non trouvé. Installez-le avec 'dotnet tool install -g csharpier'",
      command = "dotnet tool install -g csharpier"
    })
  end
  
  -- Vérifier d'autres dépendances
  local deps = {
    { name = "go", message = "Go-lang non trouvé", warning_only = true },
    { name = "julia", message = "Julia non trouvé", warning_only = true },
    { name = "composer", message = "Composer PHP non trouvé", warning_only = true },
  }
  
  for _, dep in ipairs(deps) do
    if vim.fn.executable(dep.name) == 0 then
      table.insert(missing, dep)
    end
  end
  
  -- Afficher un message si des dépendances sont manquantes
  if #missing > 0 then
    local message = "Dépendances manquantes :\n"
    
    for _, dep in ipairs(missing) do
      local level = dep.warning_only and "WARN" or "ERROR"
      message = message .. "- " .. dep.name .. ": " .. dep.message .. " (" .. level .. ")\n"
      if dep.command then
        message = message .. "  Installez avec: " .. dep.command .. "\n"
      end
    end
    
    vim.schedule(function()
      vim.notify(message, vim.log.levels.WARN, { title = "Dépendances manquantes" })
    end)
  end
end

return M
