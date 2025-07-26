local ok_status, lspconfig = pcall(require, "nvim-lspconfig")

if not ok_status then
	return
end

lspconfig.pylsp.setup({})
