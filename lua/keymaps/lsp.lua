-- Raccourcis clavier pour les fonctionnalités LSP
-- Ces mappings seront appliqués lors de l'attachement d'un serveur LSP à un buffer

-- Fonction pour configurer les raccourcis LSP sur un buffer spécifique
local function setup_lsp_keymaps(client, bufnr)
	-- Utilitaire pour définir les raccourcis plus facilement
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	-- Navigation de code
	map("n", "gd", vim.lsp.buf.definition, "Aller à la définition")
	map("n", "gr", vim.lsp.buf.references, "Trouver les références")
	map("n", "gi", vim.lsp.buf.implementation, "Aller à l'implémentation")
	map("n", "gD", vim.lsp.buf.declaration, "Aller à la déclaration")
	map("n", "gt", vim.lsp.buf.type_definition, "Aller à la définition du type")

	-- Affichage d'informations
	map("n", "K", vim.lsp.buf.hover, "Afficher la documentation")
	map("n", "<C-k>", vim.lsp.buf.signature_help, "Afficher l'aide de signature")

	-- Refactoring et actions de code
	map("n", "<leader>rn", vim.lsp.buf.rename, "Renommer")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "Actions de code")
	map("n", "<leader>gf", vim.lsp.buf.format, "Formater le code")

	-- Diagnostic
	map("n", "[d", vim.diagnostic.goto_prev, "Diagnostic précédent")
	map("n", "]d", vim.diagnostic.goto_next, "Diagnostic suivant")
	map("n", "<leader>dl", vim.diagnostic.open_float, "Afficher le diagnostic sous le curseur")
	map("n", "<leader>dq", vim.diagnostic.setloclist, "Liste des diagnostics")

	-- Gestion du workspace
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Ajouter un dossier au workspace")
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Retirer un dossier du workspace")
	map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "Lister les dossiers du workspace")
end

-- Exporter la fonction pour l'utiliser avec on_attach dans la configuration LSP
return {
	setup = setup_lsp_keymaps,
}
