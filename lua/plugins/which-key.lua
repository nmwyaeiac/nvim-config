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
    window = {
      border = "rounded", -- bordures jolies
    },
    layout = {
      align = "center",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.register({
      -- Tes propres mappings à afficher dans le menu
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
    }, { prefix = "<leader>" })
  end,
}
