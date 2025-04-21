return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"folke/neodev.nvim", -- Aide pour la configuration Lua
		},
		config = function()
			-- Configuration pour la documentation Lua/Neovim
			require("neodev").setup()

			-- Import des modules nécessaires
			local lspconfig = require("lspconfig")
			local lsp_keymaps = require("keymaps.lsp")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Configuration des icônes pour les diagnostics
			local signs = {
				{ name = "DiagnosticSignError", text = "✘" },
				{ name = "DiagnosticSignWarn", text = "▲" },
				{ name = "DiagnosticSignHint", text = "⚑" },
				{ name = "DiagnosticSignInfo", text = "ℹ" },
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			-- Configuration globale des diagnostics
			vim.diagnostic.config({
				virtual_text = true,
				signs = { active = signs },
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Configuration fenêtres flottantes
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})

			-- Fonction d'attachement LSP commune avec keymaps
			local function on_attach(client, bufnr)
				-- Configurer les raccourcis clavier
				lsp_keymaps.setup(client, bufnr)

				-- Désactiver le formatage pour certains serveurs (si on utilise none-ls à la place)
				if client.name == "typescript" or client.name == "clangd" then
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end

				-- Ajouter un highlight pour les références sous le curseur
				if client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
					vim.api.nvim_create_autocmd("CursorHold", {
						group = "lsp_document_highlight",
						buffer = bufnr,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd("CursorMoved", {
						group = "lsp_document_highlight",
						buffer = bufnr,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end

			-- Paramètres spécifiques pour chaque serveur LSP

			-- C/C++
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--background-index",
					"--suggest-missing-includes",
					"--clang-tidy",
					"--header-insertion=iwyu",
				},
			})

			-- Python
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			})

			-- Java
			lspconfig.jdtls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				-- Notez que pour Java, une config plus avancée avec jdtls séparé
				-- est recommandée pour des fonctionnalités complètes
			})

			-- JavaScript/TypeScript (remplacé tsserver par typescript)
			lspconfig.typescript.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			})

			-- HTML
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- CSS
			lspconfig.cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- PHP
			lspconfig.phpactor.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Ruby
			lspconfig.solargraph.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- C#
			lspconfig.omnisharp.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "omnisharp" },
				enable_roslyn_analyzers = true,
				organize_imports_on_format = true,
				enable_import_completion = true,
			})

			-- Zig
			lspconfig.zls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Bash
			lspconfig.bashls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Rust
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							command = "clippy",
						},
						cargo = {
							allFeatures = true,
						},
						inlayHints = {
							typeHints = {
								enable = true,
							},
							parameterHints = {
								enable = true,
							},
						},
					},
				},
			})

			-- Lua
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- Reconnaître vim comme global pour les configs Neovim
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})

			-- Auto-configuration pour les autres serveurs LSP installés avec Mason
			require("mason-lspconfig").setup_handlers({
				function(server_name)
					-- Configuration par défaut pour les serveurs LSP non explicitement définis
					if lspconfig[server_name] and not (
						server_name == "clangd" or
						server_name == "typescript" or
						server_name == "jdtls" or
						server_name == "pyright" or
						server_name == "html" or
						server_name == "cssls" or
						server_name == "phpactor" or
						server_name == "solargraph" or
						server_name == "omnisharp" or
						server_name == "zls" or
						server_name == "bashls" or
						server_name == "rust_analyzer" or
						server_name == "lua_ls"
					) then
						lspconfig[server_name].setup({
							capabilities = capabilities,
							on_attach = on_attach,
						})
					end
				end,
			})
		end,
	},
}
