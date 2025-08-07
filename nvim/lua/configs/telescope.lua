local is_ok, telescope = pcall(require, "telescope")
if not is_ok then
	return
end

telescope.setup {
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		}
	}
}

telescope.load_extension('fzf')

local is_ok2, builtin = pcall(require, "telescope.builtin")
if not is_ok2 then
	return
end

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
-- vim.keymap.set("n", "<leader>flg", builtin.live_grep, {}) -- NOTE: requires ripgrpe
vim.keymap.set("n", "<leader>fc", function() -- fc = find by content
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
