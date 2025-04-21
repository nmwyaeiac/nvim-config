-- Configuration de base de Vim/Neovim
-- Contient les options fondamentales indépendantes des plugins

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Options de base
vim.opt.backup = false -- Pas de fichier de sauvegarde
vim.opt.clipboard = "unnamedplus" -- Synchroniser avec le presse-papier du système
vim.opt.cmdheight = 1 -- Hauteur de la ligne de commande
vim.opt.completeopt = { "menuone", "noselect" } -- Options de complétion
vim.opt.conceallevel = 0 -- Afficher normalement le texte en markdown
vim.opt.cursorline = true -- Surligner la ligne courante
vim.opt.expandtab = true -- Convertir les tabulations en espaces
vim.opt.fileencoding = "utf-8" -- Encodage des fichiers
vim.opt.hlsearch = true -- Surligner les résultats de recherche
vim.opt.ignorecase = true -- Ignorer la casse dans les recherches
vim.opt.incsearch = true -- Recherche incrémentale
vim.opt.mouse = "a" -- Autoriser la souris
vim.opt.number = true -- Afficher les numéros de ligne
vim.opt.numberwidth = 4 -- Largeur des numéros de ligne
vim.opt.pumheight = 10 -- Hauteur du menu popup
vim.opt.relativenumber = true -- Numéros de ligne relatifs
vim.opt.scrolloff = 8 -- Garder un minimum de lignes visibles autour du curseur
vim.opt.shiftwidth = 2 -- Nombre d'espaces pour l'indentation
vim.opt.showmode = false -- Ne pas afficher le mode actuel (affiché par lualine)
vim.opt.showtabline = 2 -- Toujours afficher la barre d'onglets
vim.opt.sidescrolloff = 8 -- Garder un minimum de colonnes visibles autour du curseur
vim.opt.signcolumn = "yes" -- Toujours afficher la colonne des signes (diagnostics, etc.)
vim.opt.smartcase = true -- Respecter la casse si la recherche contient une majuscule
vim.opt.smartindent = true -- Indentation intelligente
vim.opt.softtabstop = 2 -- Nombre d'espaces pour une tabulation en mode insertion
vim.opt.splitbelow = true -- Ouvrir les nouvelles fenêtres horizontales en bas
vim.opt.splitright = true -- Ouvrir les nouvelles fenêtres verticales à droite
vim.opt.swapfile = false -- Pas de fichier d'échange
vim.opt.tabstop = 2 -- Nombre d'espaces pour une tabulation
vim.opt.termguicolors = true -- Activer les couleurs 24 bits
vim.opt.timeoutlen = 300 -- Temps d'attente pour les combinaisons de touches (ms)
vim.opt.undofile = true -- Activer la persistance des annulations
vim.opt.updatetime = 300 -- Temps avant écriture du fichier d'échange (ms)
vim.opt.wrap = false -- Ne pas faire de retour à la ligne automatique
vim.opt.writebackup = false -- Ne pas créer de sauvegarde pendant l'écriture

-- Paramètres de la barre de statut
vim.opt.laststatus = 3 -- Barre de statut globale

-- Configuration de la complétion automatique
vim.opt.shortmess:append("c") -- Ne pas afficher les messages de complétion

-- Configuration de recherche
vim.opt.path:append("**") -- Recherche récursive
vim.opt.wildmenu = true -- Menu de complétion de commande amélioré
vim.opt.wildignore:append("*/node_modules/*,*/.git/*,*/tmp/*,*.so,*.swp,*.zip") -- Ignore certains dossiers/fichiers

-- Configuration du pliage de code
vim.opt.foldmethod = "expr" -- Utiliser une expression pour déterminer les plis
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Utiliser treesitter pour le pliage
vim.opt.foldenable = false -- Désactiver le pliage au démarrage
vim.opt.foldlevel = 99 -- Ouvrir tous les plis par défaut

-- Configuration des onglets pour différents langages
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "java", "cs" },
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- Restaurer la position du curseur
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line("'\"")
		if line > 1 and line <= vim.fn.line("$") then
			vim.cmd("normal! g'\"")
		end
	end,
})

-- Enlever les espaces en fin de ligne à l'enregistrement
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Recharger automatiquement les fichiers modifiés en dehors de Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Notification en cas de modification externe d'un fichier
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	callback = function()
		vim.notify("Le fichier a été modifié en dehors de l'éditeur", vim.log.levels.WARN)
	end,
})

-- Surligner lors du yank (copie)
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Définir la fenêtre de quickfix
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.opt_local.buflisted = false
	end,
})
