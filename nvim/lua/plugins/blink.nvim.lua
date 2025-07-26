return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets" 
	},
	version = "*",
	-- all modules handle lazy loading internally
	-- lazy = false,
	opts = {
		keymap = {
			-- Each keymap may be a list of commands and/or functions
			preset = "enter",
			-- Select completions
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			-- Scroll documentation
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			-- Show/hide signature
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		completion = {
			keyword = { range = "prefix" },
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
			trigger = { show_on_trigger_character = true },
			documentation = {
				auto_show = true,
			},
		},
		signature = { enabled = true },
	},
	opts_extend = { "sources.default" },
}
