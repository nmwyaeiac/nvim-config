-- Raccourcis clavier pour la navigation dans les fichiers et projets
-- Regroupe les raccourcis pour Telescope, Neo-tree et autres outils de navigation

-- Configuration pour Telescope
local function setup_telescope_keymaps()
	local telescope = require("telescope.builtin")

	-- Recherche de fichiers
	vim.keymap.set("n", "<C-p>", telescope.find_files, { desc = "Rechercher des fichiers" })
	vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Rechercher des fichiers" })

	-- Recherche de texte
	vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Recherche de texte dans tous les fichiers" })
	vim.keymap.set("n", "<leader>fw", telescope.grep_string, { desc = "Rechercher le mot sous le curseur" })

	-- Buffers et historique
	vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Liste des buffers" })
	vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Rechercher dans l'aide" })
	vim.keymap.set("n", "<leader>fr", telescope.oldfiles, { desc = "Fichiers récents" })

	-- Git
	vim.keymap.set("n", "<leader>gc", telescope.git_commits, { desc = "Liste des commits" })
	vim.keymap.set("n", "<leader>gs", telescope.git_status, { desc = "Statut Git" })
	vim.keymap.set("n", "<leader>gb", telescope.git_branches, { desc = "Branches Git" })

	-- LSP
	vim.keymap.set("n", "<leader>ls", telescope.lsp_document_symbols, { desc = "Symboles du document" })
	vim.keymap.set("n", "<leader>lS", telescope.lsp_workspace_symbols, { desc = "Symboles du workspace" })
	vim.keymap.set("n", "<leader>lr", telescope.lsp_references, { desc = "Références" })
	vim.keymap.set("n", "<leader>ld", telescope.lsp_definitions, { desc = "Définitions" })
	vim.keymap.set("n", "<leader>li", telescope.lsp_implementations, { desc = "Implémentations" })
end

-- Configuration pour Neo-tree
local function setup_neotree_keymaps()
	-- Ouverture de l'explorateur de fichiers
	vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Ouvrir l'explorateur de fichiers" })
	vim.keymap.set(
		"n",
		"<leader>e",
		":Neotree filesystem reveal left<CR>",
		{ desc = "Ouvrir l'explorateur de fichiers" }
	)

	-- Autres vues Neo-tree
	vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { desc = "Liste des buffers (flottante)" })
	vim.keymap.set("n", "<leader>gs", ":Neotree git_status reveal float<CR>", { desc = "Statut Git (flottant)" })
end

-- Configuration pour la navigation entre buffers/tabs
local function setup_buffer_navigation()
	-- Navigation entre buffers
	vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Buffer suivant" })
	vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Buffer précédent" })

	-- Navigation entre tabs
	vim.keymap.set("n", "<leader>1", "1gt", { desc = "Aller au tab 1" })
	vim.keymap.set("n", "<leader>2", "2gt", { desc = "Aller au tab 2" })
	vim.keymap.set("n", "<leader>3", "3gt", { desc = "Aller au tab 3" })
	vim.keymap.set("n", "<leader>4", "4gt", { desc = "Aller au tab 4" })
	vim.keymap.set("n", "<leader>5", "5gt", { desc = "Aller au tab 5" })
end

local function setup()
	setup_telescope_keymaps()
	setup_neotree_keymaps()
	setup_buffer_navigation()
end

return {
	setup = setup,
}
