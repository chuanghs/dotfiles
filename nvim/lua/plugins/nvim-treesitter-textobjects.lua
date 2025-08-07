return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("configs.nvim-treesitter-textobjects")
	end,
}
