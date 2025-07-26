return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
		disable_in_macro = true,
		map_cr = true,
		check_ts = true,
		ts_config = {
			lua = { "string" },
			javascript = { "template_string" },
			java = false,
		},
	},
}
