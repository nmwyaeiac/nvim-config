return {
	-- Gestionnaire de serveurs LSP, DAP, linters et formatters
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
					border = "rounded",
				},
				-- Installer automatiquement les outils quand ils sont configurés
				ensure_installed = true,
				-- Afficher un message quand l'installation est terminée
				log_level = vim.log.levels.INFO,
			})
		end,
	},

	-- Intégration entre Mason et LSP config
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				-- Serveurs LSP à installer automatiquement
				ensure_installed = {
					-- C/C++
					"clangd",

					-- Java
					"jdtls",

					-- Python
					"pyright",

					-- Web
					"html",
					"cssls",
					"typescript", -- Changé de "tsserver" à "typescript"
					"eslint",

					-- PHP
					"phpactor",

					-- Ruby
					"solargraph",

					-- C#
					"omnisharp",

					-- Zig
					"zls",

					-- Shell
					"bashls",

					-- Rust
					"rust_analyzer",

					-- Lua
					"lua_ls",

					-- Autres
					"jsonls",
					"marksman",
					"yamlls",
				},
				-- Installation automatique des serveurs
				automatic_installation = true,
			})
		end,
	},

	-- Intégration entre Mason et les outils de formatage/diagnostic
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				-- Formatters et linters à installer automatiquement
				ensure_installed = {
					-- Formatters
					"black", -- Python
					"prettier", -- JS/TS/HTML/CSS
					"stylua", -- Lua
					"clang-format", -- C/C++
					"google-java-format", -- Java
					"phpcsfixer", -- PHP
					"rubocop", -- Ruby
					"csharpier", -- C#
					"shfmt", -- Bash
					"rustfmt", -- Rust

					-- Linters
					"flake8", -- Python
					"pylint", -- Python
					"mypy", -- Python
					"eslint_d", -- JS/TS
					"shellcheck", -- Bash
					-- "luacheck", -- Supprimé car problématique
					"cpplint", -- C/C++
					"checkstyle", -- Java
					"phpcs", -- PHP
				},
				automatic_installation = true,
				handlers = {},
			})
		end,
	},

	-- Intégration entre Mason et DAP
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason-nvim-dap").setup({
				-- Débogueurs à installer automatiquement
				ensure_installed = {
					"python", -- Python (debugpy)
					"cppdbg", -- C/C++ (GDB)
					"codelldb", -- Rust, C/C++
					"js", -- JavaScript/TypeScript
					"bash-debug-adapter", -- Bash
					"javadbg", -- Java
					"netcoredbg", -- C#
				},
				automatic_installation = true,
			})
		end,
	},
}
