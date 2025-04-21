-- Raccourcis clavier pour le débogage
-- Pour une utilisation fluide de nvim-dap

local M = {}

function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")
	local widgets = require("dap.ui.widgets")

	-- Fonctions de base du débogueur
	vim.keymap.set("n", "<F5>", dap.continue, { desc = "Démarrer/Continuer le débogage" })
	vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Pas à pas principal" })
	vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Pas à pas détaillé" })
	vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Sortir de la fonction" })

	-- Gestion des points d'arrêt
	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Ajouter/retirer un point d'arrêt" })
	vim.keymap.set("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Condition du point d'arrêt: "))
	end, { desc = "Point d'arrêt conditionnel" })
	vim.keymap.set("n", "<leader>dl", function()
		dap.set_breakpoint(nil, nil, vim.fn.input("Message du point d'arrêt: "))
	end, { desc = "Point d'arrêt avec message" })
	vim.keymap.set("n", "<leader>dC", dap.clear_breakpoints, { desc = "Effacer tous les points d'arrêt" })

	-- Inspection de l'état
	vim.keymap.set("n", "<leader>dh", widgets.hover, { desc = "Variables sous le curseur" })
	vim.keymap.set("n", "<leader>dp", function()
		widgets.preview()
	end, { desc = "Aperçu de l'expression" })
	vim.keymap.set("n", "<leader>df", function()
		widgets.centered_float(widgets.frames)
	end, { desc = "Pile d'appels" })
	vim.keymap.set("n", "<leader>ds", function()
		widgets.centered_float(widgets.scopes)
	end, { desc = "Portées des variables" })

	-- Contrôle de l'interface
	vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Afficher/masquer l'interface de débogage" })
	vim.keymap.set("n", "<leader>de", dap.terminate, { desc = "Arrêter le débogage" })

	-- Intégration avec Telescope
	vim.keymap.set("n", "<leader>dcc", function()
		require("telescope").extensions.dap.commands({})
	end, { desc = "Liste des commandes DAP" })
	vim.keymap.set("n", "<leader>dcf", function()
		require("telescope").extensions.dap.configurations({})
	end, { desc = "Liste des configurations DAP" })
	vim.keymap.set("n", "<leader>dlb", function()
		require("telescope").extensions.dap.list_breakpoints({})
	end, { desc = "Liste des points d'arrêt" })
	vim.keymap.set("n", "<leader>dv", function()
		require("telescope").extensions.dap.variables({})
	end, { desc = "Liste des variables" })
	vim.keymap.set("n", "<leader>df", function()
		require("telescope").extensions.dap.frames({})
	end, { desc = "Liste des frames" })
end

return M
