vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })

local clangd_options = {
    on_attach = on_attach,
    settings = {
        clangd = {
            init_options = { clangdFileStatus = true },
            cmd = {
                "clangd", 
                "--background-index",
                "--clang-tidy",
                "--clang-tidy-checks=bugprone-*, clang-analyzer-*, google-*, modernize-*, performance-*, portability-*, readability-*, -bugprone-too-small-loop-variable, -clang-analyzer-cplusplus.NewDelete, -clang-analyzer-cplusplus.NewDeleteLeaks, -modernize-use-nodiscard, -modernize-avoid-c-arrays, -readability-magic-numbers, -bugprone-branch-clone, -bugprone-signed-char-misuse, -bugprone-unhandled-self-assignment, -clang-diagnostic-implicit-int-float-conversion, -modernize-use-auto, -modernize-use-trailing-return-type, -readability-convert-member-functions-to-static, -readability-make-member-function-const, -readability-qualified-auto, -readability-redundant-access-specifiers,",
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                "--function-arg-placeholders=false",
                "--log=verbose",
                "--ranking-model=decision_forest",
                "--header-insertion-decorators",
                "-j=12",
                "--pretty",
            }
        }
    }
}
local gopls_options = {
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    on_attach = on_attach,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            hints = {
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
            },
            semanticTokens = true,
        },
    },
}
local lua_ls_options = {
    on_attach = on_attach,
    settings = {
        Lua = {
            completion = {
                callSnippet = "Replace"
            }
        }
    }
}
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

local update_option = function(opts)
    local lspconfig = require('lspconfig')
    local lsp_status = require('lsp-status')
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_extend('keep', lsp_capabilities or {}, lsp_status.capabilities)
    lsp_status.register_progress()
    opts.on_attach = lsp_status.on_attach
    lsp_capabilities = vim.tbl_extend('keep', require('cmp_nvim_lsp').default_capabilities() or {}, lsp_capabilities)
    opts.capabilities = lsp_capabilities
    return opts
end

local config = function()
    local lspconfig = require('lspconfig')
    local lsp_status = require('lsp-status')
    require("neodev").setup({})

    clangd_options.handlers = lsp_status.extensions.clangd.setup()

    clangd_options = update_option(clangd_options)
    lua_ls_options = update_option(lua_ls_options)
    gopls_options = update_option(gopls_options)

    lspconfig.clangd.setup {clangd_options}
    lspconfig.gopls.setup {gopls_options}
    lspconfig.lua_ls.setup {lua_ls_options}
end

return {
    'neovim/nvim-lspconfig', -- Required
    config = config,
    dependencies = {
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
        { 'nvim-lua/lsp-status.nvim' },
    }
}
