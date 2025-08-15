return {
	'nvim-orgmode/orgmode',
	event = 'VeryLazy',
	ft = { 'org' },
	config = function()
		-- Setup orgmode
		require('orgmode').setup({
			org_agenda_files = '~/orgfiles/**/*.org',
			org_default_notes_file = '~/orgfiles/journal.org',
			org_todo_keywords = { 'NA', 'WAITING', '|', 'DONE', 'CANCEL'},
			org_capture_templates = {
				t = { description = 'Task', headline="Inbox", template = '* NA %?\n  %u', target = "~/orgfiles/journal.org"},
				j = { description = 'Journal Entry', template = "* %U\n%?", target="~/orgfiles/journal.org", datetree=true}
			}
		})

		-- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
		-- add ~org~ to ignore_install
		-- require('nvim-treesitter.configs').setup({
		--   ensure_installed = 'all',
		--   ignore_install = { 'org' },
		-- })
	end,
}
