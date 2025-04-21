return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text", -- Montrer les valeurs dans le code
			"nvim-telescope/telescope-dap.nvim", -- Integration Telescope
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			-- Configuration de dap-ui
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "↩",
						run_last = "↺",
						terminate = "□",
					},
				},
			})

			-- Ouvrir/fermer dapui automatiquement
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Configuration de nvim-dap-virtual-text
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
			})

			-- Configuration pour Python
			dap.adapters.python = {
				type = "executable",
				command = "python",
				args = { "-m", "debugpy.adapter" },
			}

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						-- Détecte automatiquement l'environnement Python actif
						local venv = os.getenv("VIRTUAL_ENV")
						if venv then
							return venv .. "/bin/python"
						end
						return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
					end,
				},
			}

			-- Configuration pour C/C++
			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/bin/lldb-vscode", -- Chemin à adapter selon votre installation
				name = "lldb",
			}

			dap.configurations.cpp = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
			}
			dap.configurations.c = dap.configurations.cpp

			-- Configuration pour Java
			-- Nécessite java-debug et vscode-java-test installés
			-- Normalement géré par jdtls

			-- Configuration pour Rust
			dap.configurations.rust = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						local metadata = vim.fn.system("cargo metadata --format-version 1")
						local metadata_json = vim.fn.json_decode(metadata)
						local target_dir = metadata_json.target_directory
						local binary_name = metadata_json.packages[1].targets[1].name
						return target_dir .. "/debug/" .. binary_name
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			-- Configuration pour C#
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "launch - netcoredbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
				},
			}

			-- Configuration pour JavaScript/TypeScript via vscode-js-debug
			-- Cette partie nécessite l'installation et la configuration de vscode-js-debug

			-- Intégration avec Telescope
			require("telescope").load_extension("dap")
		end,
	},

	-- Ajout de mason-nvim-dap pour installer automatiquement les adaptateurs
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"python",
					"cppdbg",
					"codelldb",
					"js",
					"bash",
				},
				automatic_installation = true,
				handlers = {
					function(config)
						-- Tous les adaptateurs qui ne sont pas gérés spécifiquement
						require("mason-nvim-dap").default_setup(config)
					end,
				},
			})
		end,
	},
}

