return {
	{
		"sainnhe/sonokai",
		priority = 1000,
		config = function()
			vim.g.sonokai_transparent_background = "1"
			vim.g.sonokai_enable_italic = "1"
			vim.g.sonokai_style = "andromeda"
			vim.cmd.colorscheme("sonokai")
			-- Fond transparent pour la fenêtre de complétion
			vim.api.nvim_set_hl(0, "CmpNormal", { bg = "NONE" })

			-- Bordure blanche
			vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#ffffff", bg = "NONE" })

			-- Optionnel : pour ligne sélectionnée
			vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#ffffff", fg = "#000000" }) -- ligne surlignée
			-- Exemple pour rendre une fenêtre flottante transparente
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" }) -- Enlève le fond de la fenêtre flottante
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "#ffffff" }) -- Pour la bordure de la fenêtre flottante
		end,
	},
}
