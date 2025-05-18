-- lua/plugins/colorizer.lua
return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    -- Utiliser la fonction de compatibilité pour éviter l'avertissement vim.tbl_flatten
    local compat = require("utils.compat")
    
    -- Remplacer l'appel à la version obsolète si le plugin l'utilise
    -- (Note: ceci est un patch minimal, idéalement le plugin devrait être mis à jour)
    local colorizer = require("colorizer")
    
    -- Sauvegarde de la fonction originale si besoin de restauration
    local original_setup = colorizer.setup
    
    -- Remplacer la fonction setup avec une version qui utilise notre compat
    if vim.fn.has("nvim-0.10") == 1 then
      -- Seulement pour Neovim 0.10+ où tbl_flatten est obsolète
      colorizer.setup = function(...)
        -- Patch pour la manipulation de tableau à l'intérieur du plugin
        local restore = compat.patch_tbl_flatten_calls()
        
        -- Appel de la fonction originale
        local result = original_setup(...)
        
        -- Restaurer la fonction originale (optionnel)
        restore()
        
        return result
      end
    end
    
    -- Configurer colorizer avec les options normales
    colorizer.setup({
      "*",
      css = { rgb_fn = true },
    })
  end,
}
