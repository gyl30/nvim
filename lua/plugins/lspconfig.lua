vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })

vim.diagnostic.config {
    virtual_text = false,
    underline = false,
    update_in_insert = false,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
}


local on_init = function(client, initialization_result)
    if client.name == 'gopls' and not client.server_capabilities.semanticTokensProvider then
        client.server_capabilities.semanticTokensProvider = {
            full = true,
            range = true,
            legend = {
                tokenTypes = { 'namespace', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter', 'parameter', 'variable', 'property', 'enumMember', 'event', 'function', 'method', 'macro', 'keyword', 'modifier', 'comment', 'string', 'number', 'regexp', 'operator', 'decorator' },
                tokenModifiers = { 'declaration', 'definition', 'readonly', 'static', 'deprecated', 'abstract', 'async', 'modification', 'documentation', 'defaultLibrary'}
            },
        }
    end
end
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    local builtin = require('telescope.builtin')

    if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint(bufnr, true)
    end
    print(vim.inspect(client))
    vim.notify(bufnr)
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
    vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
    if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local lsp_references_au_id = vim.api.nvim_create_augroup("LSP_document_highlight", { clear = false })
        vim.api.nvim_clear_autocmds({
            buffer = bufnr,
            group = lsp_references_au_id,
        })
        vim.api.nvim_create_autocmd("CursorHold", {
            callback = function() vim.lsp.buf.document_highlight() end,
            buffer = bufnr,
            group = lsp_references_au_id,
            desc = "LSP document highlight",
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "WinLeave" }, {
            callback = function() vim.lsp.buf.clear_references() end,
            buffer = bufnr,
            group = lsp_references_au_id,
            desc = "Clear LSP document highlight",
        })
    end
end

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

local servers = {
    "clangd",
    "gopls",
    "lua_ls",
}

local lsp_config = function()
    local lspconfig = require("lspconfig")
    for _, server in ipairs(servers) do
        lspconfig[server].setup({
            on_init = function(client, initialization_result)
                vim.inspect(client)
                vim.inspect(initialization_result)
            end,
            on_attach = function(client, bufnr)
                vim.inspect(client)
                vim.inspect(bufnr)
            end,
        })
    end
end
return {
    'neovim/nvim-lspconfig', -- Required
    config = lsp_config,
    dependencies = {
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
        { 'nvim-lua/lsp-status.nvim' },
    }
}
