return {
	"Tsuzat/NeoSolarized.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("configs.neosolarized")
--		vim.cmd[[ colorscheme NeoSolarized ]]
	end
}
