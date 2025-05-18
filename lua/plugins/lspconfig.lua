-- lua/plugins/lspconfig.lua
return {
  -- nvim-lspconfig [configurations lsp]
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "b0o/SchemaStore.nvim", -- JSON/YAML schémas supplémentaires
    },
    config = function()
      -- S'assurer que les variables globales nécessaires sont définies
      vim.g.diagnostics_mode = vim.g.diagnostics_mode or 3
      vim.g.lsp_round_borders_enabled = vim.g.lsp_round_borders_enabled or true
      
      -- Initialiser les configurations LSP par défaut
      require("utils.lsp").apply_default_lsp_settings()
    end
  },
}
