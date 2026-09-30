require('lsp.progress')
vim.lsp.log.set_level('off')

local function gopls_organize_imports(client, bufnr)
    local encoding = client.offset_encoding or 'utf-8'

    local params = vim.lsp.util.make_range_params(bufnr, encoding)
    params.context = {
        only = { 'source.organizeImports' },
        diagnostics = {},
    }

    local result = vim.lsp.buf_request_sync(
        bufnr,
        'textDocument/codeAction',
        params,
        3000
    )

    for cid, res in pairs(result or {}) do
        for _, action in pairs(res.result or {}) do
            if action.edit then
                local c = vim.lsp.get_client_by_id(cid)
                local enc = c and c.offset_encoding or encoding
                vim.lsp.util.apply_workspace_edit(action.edit, enc)
            end
        end
    end
end
local function lsp_token_hi()
    for group, highlight in pairs({
        LspInlayHint = {
            fg = '#9DA9A0',
        },

        ['@lsp.mod.defaultLibrary'] = {
            italic = true,
        },
        ['@lsp.mod.mutable.cpp'] = {
            italic = true,
        },
        ['@lsp.mod.readonly'] = {
            italic = true,
        },
        ['@lsp.typemod.method.trait.cpp'] = {
            italic = true,
        },

        ['@lsp.type.class'] = {
            fg = '#7aa2f7',
        },
        ['@lsp.type.function'] = {
            fg = '#bb9af7',
        },
        ['@lsp.type.method'] = {
            fg = '#ff9e64',
        },
        ['@lsp.type.parameter'] = {
            fg = '#9ece6a',
        },
        ['@lsp.type.variable'] = {
            fg = '#e0af68',
        },
        ['@lsp.type.property'] = {
            fg = '#73daca',
        },

        ['@lsp.typemod.function.classScope'] = {
            fg = '#ff9e64',
        },
        ['@lsp.typemod.variable.globalScope'] = {
            fg = '#f7768e',
        },
    }) do
        vim.api.nvim_set_hl(0, group, highlight)
    end
end

local color_scheme_group = vim.api.nvim_create_augroup(
    'LspHighlights',
    { clear = true }
)

vim.api.nvim_create_autocmd('ColorScheme', {
    group = color_scheme_group,
    callback = lsp_token_hi,
})

local on_attach = function(client, bufnr)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set('n', '<leader>lr', function() vim.cmd.lsp('restart') end, { buffer = bufnr })
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    if client:supports_method('textDocument/inlayHint') then
        vim.keymap.set('n', '<leader>ih', function()
            vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                { bufnr = bufnr }
            )
        end, {
            buffer = bufnr,
        })
    end

    if client:supports_method('textDocument/documentHighlight') then
        local group = vim.api.nvim_create_augroup(
            'LspCursorHighlights_' .. bufnr,
            { clear = true }
        )
        vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end


    if client:supports_method('textDocument/formatting') then
        vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<cr>', { buffer = bufnr })
    end

    if client.server_capabilities.semanticTokensProvider then
        vim.treesitter.stop(bufnr)
    end
    if client.name == 'gopls' then
        local group = vim.api.nvim_create_augroup('GoplsSourceOrganizeImports_' .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = group,
            buffer = bufnr,
            callback = function()
                gopls_organize_imports(client, bufnr)
                vim.lsp.buf.format({
                    bufnr = bufnr,
                    async = false,
                    timeout_ms = 3000,
                    filter = function(c)
                        return c.name == 'gopls'
                    end,
                })
            end,
        })
    end
end



local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
    return signature_help {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

vim.lsp.config('*', {
    on_attach = on_attach,
    root_markers = { '.git', },
})

local lsp_configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file('lsp/*', true)) do
    local name = vim.fn.fnamemodify(v, ':t:r')
    lsp_configs[name] = true
end

vim.lsp.enable(vim.tbl_keys(lsp_configs))

vim.api.nvim_create_autocmd('LspDetach', { command = 'setl foldexpr<' })
