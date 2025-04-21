return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"clangd", -- C/C++
					"jdtls", -- Java
					"pyright", -- Python
					"html", -- HTML
					"cssls", -- CSS
					"ts_ls", -- JS/TS
					"phpactor", -- PHP
					"solargraph", -- Ruby
					"omnisharp", -- C#
					"zls", -- Zig
					"bashls", -- Bash
					"rust_analyzer", -- Rust
					"lua_ls", -- Lua
				},
			})
		end,
	},
}
