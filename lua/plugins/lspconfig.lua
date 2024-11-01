vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
vim.lsp.set_log_level("off")

vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
end

vim.diagnostic.config {
    virtual_text = false
}

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
            threads = 0,
            initialBlacklist = { "/(test|unittests)/" },
        },
        highlight = {
            rainbow = 10,
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
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--clang-tidy-checks=bugprone-*, clang-analyzer-*, google-*, modernize-*, performance-*, portability-*, readability-*, -bugprone-too-small-loop-variable, -clang-analyzer-cplusplus.NewDelete, -clang-analyzer-cplusplus.NewDeleteLeaks, -modernize-use-nodiscard, -modernize-avoid-c-arrays, -readability-magic-numbers, -bugprone-branch-clone, -bugprone-signed-char-misuse, -bugprone-unhandled-self-assignment, -clang-diagnostic-implicit-int-float-conversion, -modernize-use-auto, -modernize-use-trailing-return-type, -readability-convert-member-functions-to-static, -readability-make-member-function-const, -readability-qualified-auto, -readability-redundant-access-specifiers,",
                "--all-scopes-completion",
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--pch-storage=memory",
                "--completion-parse=auto",
                "--function-arg-placeholders=false",
                "--ranking-model=decision_forest",
                "--pretty",
                "--compile-commands-dir=build",
                "--header-insertion-decorators",
                "--enable-config",
                "--pretty",
            }
        }
    }
}

local config = function()
    require("neodev").setup({})
    local lspconfig = require 'lspconfig'
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_extend('force', require('cmp_nvim_lsp').default_capabilities() or {}, lsp_capabilities)
    lsp_capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }
    lsp_capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
            properties = {
                "documentation",
                "detail",
                "additionalTextEdits",
            },
        },
    }
    gopls_options.capabilities = lsp_capabilities
    clangd_options.capabilities = lsp_capabilities
    clangd_options.capabilities.offsetEncoding = { "utf-32" }
    ccls_options.capabilities = lsp_capabilities
    lua_ls_options.capabilities = lsp_capabilities
    lspconfig.gopls.setup(gopls_options)
    lspconfig.clangd.setup(clangd_options)
    lspconfig.ccls.setup(ccls_options)
    lspconfig.lua_ls.setup(lua_ls_options)
end
local func_colors = {
    '#e5b124', '#927754', '#eb992c', '#e2bf8f', '#d67c17',
    '#88651e', '#e4b953', '#a36526', '#b28927', '#d69855',
}
local type_colors = {
    '#e1afc3', '#d533bb', '#9b677f', '#e350b6', '#a04360',
    '#dd82bc', '#de3864', '#ad3f87', '#dd7a90', '#e0438a',
}
local param_colors = {
    '#e5b124', '#927754', '#eb992c', '#e2bf8f', '#d67c17',
    '#88651e', '#e4b953', '#a36526', '#b28927', '#d69855',
}
local var_colors = {
    '#429921', '#58c1a4', '#5ec648', '#36815b', '#83c65d',
    '#419b2f', '#43cc71', '#7eb769', '#58bf89', '#3e9f4a',
}
local all_colors = {
    class = type_colors,
    constructor = func_colors,
    enum = type_colors,
    enumMember = var_colors,
    field = var_colors,
    ['function'] = func_colors,
    method = func_colors,
    parameter = param_colors,
    struct = type_colors,
    typeAlias = type_colors,
    typeParameter = type_colors,
    variable = var_colors
}
for type, colors in pairs(all_colors) do
    for i = 1, #colors do
        vim.api.nvim_set_hl(0, string.format('@lsp.typemod.%s.id%s.cpp', type, i - 1), { fg = colors[i] })
    end
end

vim.cmd([[
hi @lsp.mod.classScope.cpp gui=italic
hi @lsp.mod.static.cpp gui=bold
hi @lsp.typemod.variable.namespaceScope.cpp gui=bold,underline
]])
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
