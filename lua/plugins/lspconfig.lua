local format_on_save = function(client)
    if client.supports_method('textDocument/formatting') then
        local lsp_format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = lsp_format_augroup,
            callback = function()
                if vim.fn.has('nvim-0.8') == 1 then
                    vim.lsp.buf.format()
                else
                    vim.lsp.buf.formatting_sync({}, 1000)
                end
            end,
        })
    end
end
local set_mappings = function(bufnr, mappings)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    for key, cmd in pairs(mappings or {}) do
        if type(cmd) == 'string' and cmd:find('^lua') ~= nil then
            cmd = ':' .. cmd .. '<cr>'
        end
        vim.keymap.set('n', key, cmd, opts)
    end
end
local default_mappings = function(bufnr, mappings)
    local defaults = {
        gD = vim.lsp.buf.declaration,
        gd = vim.lsp.buf.definition,
        gi = vim.lsp.buf.implementation,
        gr = vim.lsp.buf.references,
        K = vim.lsp.buf.hover,
        ['<C-k>'] = vim.lsp.buf.signature_help,
        ['<leader>rn'] = vim.lsp.buf.rename,
        ['<localleader>qf'] = vim.lsp.buf.code_action,
        ['<localleader>ft'] = vim.lsp.buf.formatting, -- compatible with nvim-0.7
        ['<space>e'] = vim.diagnostic.open_float,
        ['[d'] = vim.diagnostic.goto_prev,
        [']d'] = vim.diagnostic.goto_next,
    }
    mappings = vim.tbl_deep_extend('keep', mappings or {}, defaults)
    set_mappings(bufnr, mappings)
end

local clangd_config_func = function(options)
    require("lspconfig").clangd.setup({
        on_attach = options.on_attach,
        capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, options.capabilities),
        single_file_support = true,
        cmd = {
            "clangd",
            "--background-index",
            "--pch-storage=memory",
            "--clang-tidy",
            "--all-scopes-completion",
            "--completion-style=detailed",
            "--header-insertion-decorators",
        },
    })
end



return {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { 'williamboman/mason.nvim',          config = true, cmd = "Mason" },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'j-hui/fidget.nvim',                config = true },
        { 'folke/neodev.nvim',                config = true },
        { 'hrsh7th/cmp-nvim-lsp' },
    },

    config = function()
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
            vim.lsp.handlers.hover,
            { border = 'rounded' }
        )

        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            {
                border = 'rounded',
                close_events = { "CursorMoved", "BufHidden", "InsertCharPre" }
            }
        )
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            signs = true,
            underline = true,
            virtual_text = true,
            update_in_insert = false,
        })

        local lsp_defaults = {
            capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
            vim.lsp.protocol.make_client_capabilities(),
            on_attach = function(client, bufnr)
                vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
                format_on_save(client)
                default_mappings(bufnr, {})
            end
        }

        local mason_lspconfig = require('mason-lspconfig')
        mason_lspconfig.setup {
            ensure_installed = { "clangd", "gopls" },
            on_attach = lsp_defaults.on_attach,
            capabilities = lsp_defaults.capabilities,
        }

        local nvim_lsp = require('lspconfig')
        local function mason_handler(lsp_name)
            if lsp_name == "clangd" then
                clangd_config_func(lsp_defaults)
            else
                nvim_lsp[lsp_name].setup(lsp_defaults)
            end
        end
        mason_lspconfig.setup_handlers({ mason_handler })
    end
}
