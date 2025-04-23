return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true, -- intégration avec treesitter si disponible
			ts_config = {
				lua = { "string" }, -- ne pas ajouter de paires dans les chaînes de caractères Lua
				javascript = { "template_string" }, -- même chose pour JS
				java = false, -- ne pas utiliser treesitter pour java
			},
			fast_wrap = {
				map = "<M-e>", -- Alt+e pour entourer rapidement avec des paires
				chars = { "{", "[", "(", '"', "'" },
				pattern = [=[[%'%"%>%]%)%}%,]]=],
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "Search",
				highlight_grey = "Comment",
			},
			disable_filetype = { "TelescopePrompt", "vim" },
			disable_in_macro = false,
			disable_in_visualblock = false,
			ignored_next_char = [=[[%w%%%'%[%"%.]]=],
			enable_moveright = true,
			enable_afterquote = true,
			enable_check_bracket_line = true,
			enable_bracket_in_quote = true,
		},
		config = function(_, opts)
			local npairs = require("nvim-autopairs")
			npairs.setup(opts)

			-- Si tu utilises nvim-cmp pour l'autocomplétion,
			-- Tu peux aussi ajouter cette intégration :
			-- (décommente ces lignes si tu utilises nvim-cmp)

			-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			-- local cmp = require("cmp")
			-- cmp.event:on(
			--   "confirm_done",
			--   cmp_autopairs.on_confirm_done()
			-- )
		end,
	},
}
