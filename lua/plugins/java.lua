-- lua/plugins/java.lua
return {
  "nvim-java/nvim-java",  -- Nouveau repository (au lieu de zeioth/nvim-java)
  ft = { "java" },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "nvim-java/lua-async-await",  -- Dépendance importante
    "nvim-java/nvim-java-core",   -- Dépendance manquante
    "nvim-java/nvim-java-test",   -- Support de tests
    "nvim-java/nvim-java-dap",    -- Support de débogage
  },
  opts = {
    -- Configuration de base
    jdk = {
      auto_install = true,        -- Installation automatique du JDK si nécessaire
    },
    jdtls = {
      auto_install = true,        -- Installation automatique de jdtls
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "automatic",
          },
          maven = {
            downloadSources = true,
          },
          import = {
            maven = {
              enabled = true,
            },
            gradle = {
              enabled = true,
            },
          },
          format = {
            enabled = true,
          },
          completion = {
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.jupiter.api.Assertions.*",
            },
          },
        },
      },
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
    notifications = {
      enabled = true,  -- Activer les notifications
      dap = false,     -- Désactiver les notifications DAP
    },
  },
}
