vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
-- vim.lsp.set_log_level("off")

vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
end

vim.diagnostic.config {
    virtual_text = false
}
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
local ns = vim.api.nvim_create_namespace('CurlineDiag')
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.api.nvim_create_autocmd('CursorHold', {
            buffer = args.buf,
            callback = function()
                pcall(vim.api.nvim_buf_clear_namespace, args.buf, ns, 0, -1)
                local hi = { 'Error', 'Warn', 'Info', 'Hint' }
                local curline = vim.api.nvim_win_get_cursor(0)[1]
                local diagnostics = vim.diagnostic.get(args.buf, { lnum = curline - 1 })
                local virt_texts = { { (' '):rep(4) } }
                for _, diag in ipairs(diagnostics) do
                    virt_texts[#virt_texts + 1] = { diag.message, 'Diagnostic' .. hi[diag.severity] }
                end
                vim.api.nvim_buf_set_extmark(args.buf, ns, curline - 1, 0, {
                    virt_text = virt_texts,
                    hl_mode = 'combine'
                })
            end
        })
    end
})
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.cmd([[highlight DiagnosticFloatingError guibg=NONE guifg=NONE gui=underline]])
    vim.cmd([[highlight DiagnosticFloatingWarn guibg=NONE guifg=NONE gui=underline]])
    vim.cmd([[highlight DiagnosticFloatingInfo guibg=NONE guifg=NONE gui=underline]])
    vim.cmd([[highlight DiagnosticFloatingHint guibg=NONE guifg=NONE gui=underline]])
    if client.supports_method 'textDocument/documentHighlight' then
        vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })
        vim.api.nvim_clear_autocmds { buffer = bufnr, group = 'lsp_document_highlight' }
        vim.api.nvim_create_autocmd('CursorHold', {
            callback = vim.lsp.buf.document_highlight,
            buffer = bufnr,
            group = 'lsp_document_highlight',
            desc = 'Document Highlight',
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
            group = 'lsp_document_highlight',
            desc = 'Clear All the References',
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
end

local lua_ls_options = {
    on_attach = on_attach,
    settings = {
        Lua = {
            telemetry = { enable = false },
            runtime = {
                version = "LuaJIT",
                special = {
                    reload = "require",
                },
            },
            diagnostics = {
                globals = { "vim", "reload" },
            },
            completion = {
                callSnippet = "Replace"
            },
            workspace = {
                library = {
                    [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                    [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                    [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        }
    }
}
local gopls_options = {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    on_attach = on_attach,
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
    },
    settings = {
        gopls = {
            staticcheck = true,
            semanticTokens = true,
            usePlaceholders = true,
            completeUnimported = true,
            gofumpt = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            hints = {
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
            },
        },
    },
}
local ccls_options = {
    init_options = {
        index = {
            threads = 8,
            initialBlacklist = { "/(test|unittests)/" },
        },
        cache = {
            directory = "/tmp/ccls-cache",
        },
    }
}
local clangd_options = {
    on_attach = on_attach,
    settings = {
        clangd = {
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        }
    },
    cmd = {
        "clangd",
        "-j=8",
        "--pretty",
        "--clang-tidy",
        "--enable-config",
        "--background-index",
        "--cross-file-rename",
        "--pch-storage=memory",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--compile-commands-dir=build",
        "--clang-tidy-checks=bugprone-*, clang-analyzer-*, google-*, modernize-*, performance-*, portability-*, readability-*, -bugprone-too-small-loop-variable, -clang-analyzer-cplusplus.NewDelete, -clang-analyzer-cplusplus.NewDeleteLeaks, -modernize-use-nodiscard, -modernize-avoid-c-arrays, -readability-magic-numbers, -bugprone-branch-clone, -bugprone-signed-char-misuse, -bugprone-unhandled-self-assignment, -clang-diagnostic-implicit-int-float-conversion, -modernize-use-auto, -modernize-use-trailing-return-type, -readability-convert-member-functions-to-static, -readability-make-member-function-const, -readability-qualified-auto, -readability-redundant-access-specifiers,",
    }

}

local config = function()
    require("neodev").setup({})
    local lspconfig = require 'lspconfig'

    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_extend('force', require('cmp_nvim_lsp').default_capabilities() or {}, lsp_capabilities)
    gopls_options.capabilities = lsp_capabilities
    clangd_options.capabilities = lsp_capabilities
    clangd_options.capabilities.offsetEncoding = { "utf-32" }
    ccls_options.capabilities = lsp_capabilities
    lua_ls_options.capabilities = lsp_capabilities
    lspconfig.gopls.setup(gopls_options)
    lspconfig.jsonls.setup({ capabilities = lsp_capabilities })
    lspconfig.pyright.setup({ capabilities = lsp_capabilities })
    lspconfig.clangd.setup(clangd_options)
    -- lspconfig.ccls.setup(ccls_options)
    lspconfig.lua_ls.setup(lua_ls_options)
end
return {
    'neovim/nvim-lspconfig',
    config = config,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { 'iguanacucumber/magazine.nvim' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'ranjithshegde/ccls.nvim' },
        { 'p00f/clangd_extensions.nvim' },
        {
            'ray-x/lsp_signature.nvim',
            config = function()
                require 'lsp_signature'.setup()
            end
        },
    }
}
