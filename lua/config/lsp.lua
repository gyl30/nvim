vim.lsp.log.set_level('off')
vim.diagnostic.config({ virtual_text = false })

vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        ---- Link LSP semantic highlight groups to TreeSitter token groups
        for lsp, link in pairs({
            ['@lsp.type.class'] = '@type',
            ['@lsp.type.decorator'] = '@function.macro',
            ['@lsp.type.enum'] = '@type',
            ['@lsp.type.enumMember'] = '@constant',
            ['@lsp.type.enumMember.rust'] = '@constant',
            ['@lsp.type.function'] = '@function',
            ['@lsp.type.interface'] = '@type',
            ['@lsp.type.macro'] = '@function.macro',
            ['@lsp.type.method'] = '@method',
            ['@lsp.type.namespace'] = '@namespace',
            ['@lsp.type.parameter'] = '@parameter',
            ['@lsp.type.property'] = '@property',
            ['@lsp.type.struct'] = '@type',
            ['@lsp.type.type'] = '@type',
            ['@lsp.type.variable'] = '@variable',
        }) do
            vim.api.nvim_set_hl(0, lsp, { link = link, default = true })
        end

        for k, v in pairs({
            ['@attribute'] = { link = 'PreProc', default = true },
            ['@boolean'] = { link = 'Boolean', default = true },
            ['@character'] = { link = 'Character', default = true },
            ['@character.special'] = { link = 'SpecialChar', default = true },
            ['@comment'] = { link = 'Comment', default = true },
            ['@comment.error'] = { link = 'Error', default = true },
            ['@comment.note'] = { link = 'SpecialComment', default = true },
            ['@comment.todo'] = { link = 'Todo', default = true },
            ['@comment.warning'] = { link = 'WarningMsg', default = true },
            ['@conditional'] = { link = 'Conditional', default = true },
            ['@constant'] = { link = 'Constant', default = true },
            ['@constant.builtin'] = { link = 'Constant', default = true },
            ['@constant.macro'] = { link = 'Define', default = true },
            ['@constructor'] = { link = 'Special', default = true },
            ['@debug'] = { link = 'Debug', default = true },
            ['@define'] = { link = 'Define', default = true },
            ['@exception'] = { link = 'Exception', default = true },
            ['@field'] = { link = 'Identifier', default = true },
            ['@float'] = { link = 'Float', default = true },
            ['@function'] = { link = 'Function', default = true },
            ['@function.builtin'] = { link = 'Special', default = true },
            ['@function.macro'] = { link = 'Macro', default = true },
            ['@function.method'] = { link = 'Function', default = true },
            ['@include'] = { link = 'Include', default = true },
            ['@keyword'] = { link = 'Keyword', default = true },
            ['@keyword.conditional'] = { link = 'Conditional', default = true },
            ['@keyword.debug'] = { link = 'Debug', default = true },
            ['@keyword.directive'] = { link = 'PreProc', default = true },
            ['@keyword.exception'] = { link = 'Exception', default = true },
            ['@keyword.function'] = { link = 'Keyword', default = true },
            ['@keyword.import'] = { link = 'Include', default = true },
            ['@keyword.operator'] = { link = 'Operator', default = true },
            ['@keyword.repeat'] = { link = 'Repeat', default = true },
            ['@keyword.return'] = { link = 'Keyword', default = true },
            ['@label'] = { link = 'Label', default = true },
            ['@macro'] = { link = 'Macro', default = true },
            ['@markup.emphasis'] = { italic = true, default = true },
            ['@markup.environment'] = { link = 'Macro', default = true },
            ['@markup.heading'] = { link = 'Title', default = true },
            ['@markup.link'] = { link = 'Underlined', default = true },
            ['@markup.link.label'] = { link = 'SpecialChar', default = true },
            ['@markup.link.url'] = { link = 'Keyword', default = true },
            ['@markup.list'] = { link = 'Keyword', default = true },
            ['@markup.math'] = { link = 'Special', default = true },
            ['@markup.raw'] = { link = 'SpecialComment', default = true },
            ['@markup.strike'] = { strikethrough = true, default = true },
            ['@markup.strong'] = { bold = true, default = true },
            ['@markup.underline'] = { underline = true, default = true },
            ['@method'] = { link = 'Function', default = true },
            ['@module'] = { link = 'Identifier', default = true },
            ['@namespace'] = { link = 'Identifier', default = true },
            ['@number'] = { link = 'Number', default = true },
            ['@number.float'] = { link = 'Float', default = true },
            ['@operator'] = { link = 'Operator', default = true },
            ['@parameter'] = { link = 'Identifier', default = true },
            ['@preproc'] = { link = 'PreProc', default = true },
            ['@property'] = { link = 'Identifier', default = true },
            ['@punctuation'] = { link = 'Delimiter', default = true },
            ['@punctuation.bracket'] = { link = 'Delimiter', default = true },
            ['@punctuation.delimiter'] = { link = 'Delimiter', default = true },
            ['@punctuation.special'] = { link = 'Delimiter', default = true },
            ['@repeat'] = { link = 'Repeat', default = true },
            ['@storageclass'] = { link = 'StorageClass', default = true },
            ['@string'] = { link = 'String', default = true },
            ['@string.escape'] = { link = 'SpecialChar', default = true },
            ['@string.regexp'] = { link = 'String', default = true },
            ['@string.special'] = { link = 'SpecialChar', default = true },
            ['@string.special.symbol'] = { link = 'Identifier', default = true },
            ['@structure'] = { link = 'Structure', default = true },
            ['@tag'] = { link = 'Tag', default = true },
            ['@tag.attribute'] = { link = 'Identifier', default = true },
            ['@tag.delimiter'] = { link = 'Delimiter', default = true },
            ['@text.literal'] = { link = 'Comment', default = true },
            ['@text.reference'] = { link = 'Identifier', default = true },
            ['@text.title'] = { link = 'Title', default = true },
            ['@text.todo'] = { link = 'Todo', default = true },
            ['@text.underline'] = { link = 'Underlined', default = true },
            ['@text.uri'] = { link = 'Underlined', default = true },
            ['@type'] = { link = 'Type', default = true },
            ['@type.builtin'] = { link = 'Type', default = true },
            ['@type.definition'] = { link = 'Typedef', default = true },
            ['@type.qualifier'] = { link = 'Type', default = true },
            ['@variable'] = { link = 'Variable', default = true },
            ['@variable.builtin'] = { link = 'Special', default = true },
            ['@variable.member'] = { link = 'Identifier', default = true },
            ['@variable.parameter'] = { link = 'Identifier', default = true },
        }) do
            vim.api.nvim_set_hl(0, k, v)
        end
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#9DA9A0" })
        vim.api.nvim_set_hl(0, '@lsp.mod.defaultLibrary', { italic = true, default = true })
        vim.api.nvim_set_hl(0, '@lsp.mod.deprecated', { strikethrough = true, default = true })
        vim.api.nvim_set_hl(0, '@lsp.mod.mutable.cpp', { italic = true, default = true })
        vim.api.nvim_set_hl(0, '@lsp.typemod.method.trait.cpp', { italic = true, default = true })
        vim.api.nvim_set_hl(0, '@lsp.mod.readonly', { italic = true })
        vim.api.nvim_set_hl(0, '@lsp.type.class', { fg = '#7aa2f7' })     -- Blue
        vim.api.nvim_set_hl(0, '@lsp.type.function', { fg = '#bb9af7' })  -- Purple
        vim.api.nvim_set_hl(0, '@lsp.type.method', { fg = '#ff9e64' })    -- Orange
        vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg = '#9ece6a' }) -- Green
        vim.api.nvim_set_hl(0, '@lsp.type.variable', { fg = '#e0af68' })  -- Yellow
        vim.api.nvim_set_hl(0, '@lsp.type.property', { fg = '#73daca' })  -- Cyan
        vim.api.nvim_set_hl(
            0,
            '@lsp.typemod.function.classScope',
            { fg = '#ff9e64' }
        ) -- Orange
        vim.api.nvim_set_hl(
            0,
            '@lsp.typemod.variable.globalScope',
            { fg = '#f7768e' }
        ) -- Red
    end,
})
local on_attach = function(client, bufnr)
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    if client and client:supports_method('textDocument/foldingRange', bufnr) then
        vim.o.foldmethod = 'expr'
        vim.o.foldexpr = 'v:lua.vim.lsp.foldexpr()'
        vim.o.foldtext = 'v:lua.vim.lsp.foldtext()'
    end
    if client:supports_method 'textDocument/signatureHelp' then
        vim.keymap.set("i", '<C-k>', function()
            if require('blink.cmp.completion.windows.menu').win:is_open() then
                require('blink.cmp').hide()
            end

            vim.lsp.buf.signature_help()
        end)
    end
    if client:supports_method 'textDocument/documentHighlight' then
        local under_cursor_highlights_group =
            vim.api.nvim_create_augroup('LspCursorHighlights', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
            group = under_cursor_highlights_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
            group = under_cursor_highlights_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
    if client:supports_method 'textDocument/inlayHint' then
        local inlay_hints_group = vim.api.nvim_create_augroup('LspToggleInlayHints', { clear = false })
        vim.api.nvim_create_autocmd('InsertEnter', {
            group = inlay_hints_group,
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
            end,
        })

        vim.api.nvim_create_autocmd('InsertLeave', {
            group = inlay_hints_group,
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end,
        })
    end

    if client.server_capabilities.semanticTokensProvider then
        vim.treesitter.stop(bufnr)
    end
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
        })
    end
    if client.name == 'gopls' then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("GoplsSourceOrganizeImports", {}),
            callback = function()
                local params = {
                    textDocument = vim.lsp.util.make_text_document_params(0),
                    range = vim.lsp.util.make_range_params(0, 'utf-8').range,
                    context = {
                        only = { 'source.organizeImports' },
                        diagnostics = {},
                    },
                }
                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
                for _, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if next(r.edit) then
                            vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                        elseif next(r.command) then
                            client:exec_cmd({
                                title = "Organize Imports",
                                command = r.command,
                                arguments = { vim.api.nvim_buf_get_name(buf) },
                            })
                        end
                    end
                end
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
vim.lsp.config("*", {
    on_attach = on_attach,
    root_markers = { ".git", },
})
local lsp_configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file('lsp/*', true)) do
    local name = vim.fn.fnamemodify(v, ':t:r')
    lsp_configs[name] = true
end

vim.lsp.enable(vim.tbl_keys(lsp_configs))
