-- init.lua  
-- Installation automatique de lazy.nvim s'il n'est pas présent
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Configuration de base de Vim/Neovim
require("vim-config")

-- Désactiver explicitement les providers inutilisés pour éviter les avertissements
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- Définir le chemin Python si disponible
if vim.fn.executable("python3") == 1 then
  vim.g.python3_host_prog = vim.fn.exepath("python3")
else
  -- Désactiver Python provider si indisponible
  vim.g.loaded_python3_provider = 0
end

-- Chargement des raccourcis clavier généraux
require("keymaps")

-- Installer les plugins avec lazy.nvim
require("lazy").setup("plugins", {
	defaults = { lazy = false },
	install = { colorscheme = { "sonokai" } },
	checker = { enabled = true, notify = false },
	change_detection = {
		notify = false,
	},
	ui = {
		border = "rounded",
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Configuration supplémentaire après le chargement des plugins
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function()
		-- Charger la configuration des débogueurs après l'installation des plugins
		if package.loaded["dap"] and package.loaded["dapui"] then
			require("keymaps.debug").setup()
		end

		-- Charger la configuration de navigation après l'installation des plugins
		if package.loaded["telescope"] and package.loaded["neo-tree"] then
			require("keymaps.navigation").setup()
		end

		-- Message de démarrage
		print("Configuration NeoVim chargée avec succès!")
	end,
})
