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

    -- Utiliser le nouveau format spec pour les mappings (liste au lieu de tables imbriquées)
    wk.register({
      { "<leader>f", group = "Fichier" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Rechercher un fichier" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Récents" },
      { "<leader>fs", "<cmd>w<cr>", desc = "Sauvegarder" },
      
      { "<leader>b", group = "Buffers" },
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Liste des buffers" },
      { "<leader>bd", "<cmd>bd<cr>", desc = "Fermer le buffer" },
      
      { "<leader>g", group = "Git" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
      
      -- Ajouter mappings pour résoudre le conflit de chevauchement <Space>w et <Space>wq
      { "<leader>wq", "<cmd>wq<cr>", desc = "Sauvegarder et quitter" },
      { "<leader>qq", "<cmd>q!<cr>", desc = "Quitter sans sauvegarder" },
    })
  end,
}
