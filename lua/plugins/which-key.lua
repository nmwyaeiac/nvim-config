-- lua/plugins/which-key.lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      spelling = {
        enabled = true,
        suggestions = 20,
      },
    },
    -- Remplacer "window" par "win" pour corriger l'avertissement d'option obsolète
    win = {
      border = "rounded", -- bordures jolies
      padding = { 2, 2, 2, 2 }, -- espacement interne
      winblend = 0, -- transparence (0 = opaque, 100 = transparent)
    },
    layout = {
      align = "center",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Utiliser le format de table imbriquée au lieu de liste
    -- Ce format est plus stable et moins sujet aux erreurs
    wk.register({
      f = {
        name = "Fichier",
        f = { "<cmd>Telescope find_files<cr>", "Rechercher un fichier" },
        r = { "<cmd>Telescope oldfiles<cr>", "Récents" },
        s = { "<cmd>w<cr>", "Sauvegarder" },
      },
      b = {
        name = "Buffers",
        b = { "<cmd>Telescope buffers<cr>", "Liste des buffers" },
        d = { "<cmd>bd<cr>", "Fermer le buffer" },
      },
      g = {
        name = "Git",
        s = { "<cmd>Telescope git_status<cr>", "Status" },
        c = { "<cmd>Telescope git_commits<cr>", "Commits" },
      },
      w = {
        name = "Écriture", -- Ajouté pour clarifier le groupe
        s = { "<cmd>w<cr>", "Sauvegarder" },
        q = { "<cmd>wq<cr>", "Sauvegarder et quitter" },
      },
      q = {
        name = "Quitter", -- Ajouté pour clarifier le groupe
        q = { "<cmd>q!<cr>", "Quitter sans sauvegarder" },
      },
    }, { prefix = "<leader>" })
    
    -- Si vous avez besoin de mappings globaux (sans préfixe)
    wk.register({
      -- Exemple : ["<C-s>"] = { "<cmd>w<cr>", "Sauvegarder" },
    })
  end,
}
