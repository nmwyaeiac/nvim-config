-- Raccourcis clavier généraux pour l'édition et la navigation de base

-- Configuration du leader
vim.g.mapleader = " " -- Espace comme touche leader

-- Échappement plus facile du mode insertion
vim.keymap.set("i", "jk", "<Esc>", { desc = "Échapper du mode insertion" })

-- Enregistrement et sortie rapides
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Enregistrer le fichier" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quitter" })
vim.keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Enregistrer et quitter" })

-- Navigation entre les fenêtres
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Fenêtre à gauche" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Fenêtre en bas" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Fenêtre en haut" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Fenêtre à droite" })

-- Redimensionnement des fenêtres
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Réduire la hauteur" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Augmenter la hauteur" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Réduire la largeur" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Augmenter la largeur" })

-- Gestion des tampons (buffers)
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Buffer suivant" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Buffer précédent" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Supprimer le buffer" })

-- Déplacement du texte en mode visuel
vim.keymap.set("v", "J", ":move '>+1<CR>gv-gv", { desc = "Déplacer le texte vers le bas" })
vim.keymap.set("v", "K", ":move '<-2<CR>gv-gv", { desc = "Déplacer le texte vers le haut" })

-- Conserver la sélection après indentation
vim.keymap.set("v", "<", "<gv", { desc = "Diminuer l'indentation et garder la sélection" })
vim.keymap.set("v", ">", ">gv", { desc = "Augmenter l'indentation et garder la sélection" })

-- Recherche améliorée
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Désactiver le surlignage de recherche" })

-- Créer et fermer des onglets
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Nouvel onglet" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Fermer l'onglet" })

-- Mode terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Sortir du mode terminal" })
