-- lua/plugins/java.lua (nouveau fichier)
return {
  "zeioth/nvim-java",
  ft = { "java" },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "mason-org/mason.nvim",
  },
  opts = {
    notifications = {
      dap = false,
    },
    -- Marqueurs racine pour les projets Java
    root_markers = {
      "settings.gradle",
      "settings.gradle.kts",
      "pom.xml",
      "build.gradle",
      "mvnw",
      "gradlew",
      "build.gradle",
      "build.gradle.kts",
      ".git",
    },
    -- Assurez-vous que cette configuration est correcte pour jdtls
    jdtls = {
      -- Vous pouvez ajouter des configurations spécifiques à jdtls ici
    },
  },
}
