-- lua/lazy-packages.lua
-- Définit les packages externes nécessaires pour un bon fonctionnement

local M = {}

-- Vérifie si un exécutable est disponible dans le PATH
function M.is_executable(name)
  return vim.fn.executable(name) == 1
end

-- Fonction de vérification des dépendances externes
function M.check_dependencies()
  local missing = {}
  local recommended = {}
  
  -- Dépendances requises
  local required = {
    { name = "git", message = "Git est nécessaire pour installer des plugins" },
    { name = "cc", message = "Compilateur C requis pour certains plugins (tree-sitter)" },
  }
  
  -- Dépendances optionnelles mais recommandées
  local optional = {
    { name = "lldb-vscode", message = "Nécessaire pour le débogage C/C++/Rust" },
    { name = "wget", message = "Utile pour télécharger des ressources" },
    { name = "curl", message = "Utilisé pour télécharger des ressources" },
    { name = "netcoredbg", message = "Nécessaire pour le débogage C#" },
    { name = "tree-sitter", message = "Utile pour installer des grammaires personnalisées" },
    { name = "ripgrep", alternative = "rg", message = "Améliore les recherches avec Telescope" },
    { name = "fd", message = "Améliore les recherches de fichiers avec Telescope" },
  }
  
  -- Vérifier les dépendances requises
  for _, dep in ipairs(required) do
    if not M.is_executable(dep.name) then
      table.insert(missing, { name = dep.name, message = dep.message, required = true })
    end
  end
  
  -- Vérifier les dépendances optionnelles
  for _, dep in ipairs(optional) do
    local has_dep = M.is_executable(dep.name)
    
    -- Vérifier l'alternative si elle existe
    if not has_dep and dep.alternative then
      has_dep = M.is_executable(dep.alternative)
    end
    
    if not has_dep then
      table.insert(recommended, { name = dep.name, message = dep.message, required = false })
    end
  end
  
  -- Afficher les dépendances manquantes
  if #missing > 0 or #recommended > 0 then
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.schedule(function()
          local message = "Vérification des dépendances:\n\n"
          
          if #missing > 0 then
            message = message .. "Dépendances requises manquantes :\n"
            for _, dep in ipairs(missing) do
              message = message .. "- " .. dep.name .. ": " .. dep.message .. "\n"
            end
            message = message .. "\n"
          end
          
          if #recommended > 0 then
            message = message .. "Dépendances recommandées :\n"
            for _, dep in ipairs(recommended) do
              message = message .. "- " .. dep.name .. ": " .. dep.message .. "\n"
            end
          end
          
          message = message .. "\nConsultez le README pour plus d'informations sur l'installation."
          
          -- Afficher un message avec le niveau approprié
          if #missing > 0 then
            vim.notify(message, vim.log.levels.ERROR, { title = "Dépendances manquantes" })
          elseif #recommended > 0 then
            vim.notify(message, vim.log.levels.WARN, { title = "Dépendances recommandées" })
          end
        end)
      end,
      once = true,
    })
  end
  
  return #missing == 0
end

-- Fonction pour installer les packages Python nécessaires
function M.install_python_packages()
  if not M.is_executable("pip") and not M.is_executable("pip3") then
    vim.notify("Pip n'est pas installé. Impossible d'installer les packages Python.", vim.log.levels.ERROR)
    return false
  end
  
  local pip_cmd = M.is_executable("pip3") and "pip3" or "pip"
  local packages = { "pynvim" }
  
  for _, pkg in ipairs(packages) do
    vim.fn.system({ pip_cmd, "install", "--user", pkg })
  end
  
  return true
end

-- Fonction pour fournir des instructions d'installation selon le système
function M.get_installation_guide()
  local os = vim.loop.os_uname().sysname
  local guide = "Guide d'installation des dépendances:\n\n"
  
  if os == "Linux" then
    guide = guide .. "Pour Debian/Ubuntu:\n"
    guide = guide .. "sudo apt install lldb-vscode wget nodejs npm python3-pip ripgrep fd-find\n"
    guide = guide .. "pip3 install --user pynvim\n\n"
    
    guide = guide .. "Pour Arch Linux:\n"
    guide = guide .. "sudo pacman -S lldb wget nodejs npm python-pip ripgrep fd\n"
    guide = guide .. "paru -S python-pynvim\n\n"
    
    guide = guide .. "Installation de tree-sitter-cli:\n"
    guide = guide .. "npm install -g tree-sitter-cli\n"
  elseif os == "Darwin" then
    guide = guide .. "Pour macOS avec Homebrew:\n"
    guide = guide .. "brew install llvm wget node ripgrep fd\n"
    guide = guide .. "pip3 install --user pynvim\n"
    guide = guide .. "npm install -g tree-sitter-cli\n"
  elseif os:find("Windows") then
    guide = guide .. "Pour Windows avec Chocolatey:\n"
    guide = guide .. "choco install llvm wget nodejs ripgrep fd\n"
    guide = guide .. "pip install pynvim\n"
    guide = guide .. "npm install -g tree-sitter-cli\n"
  end
  
  return guide
end

return M
