return {
    cmd = { 'gopls' },

    filetypes = {
        'go',
        'gomod',
        'gowork',
        'gotmpl',
    },

    root_markers = {
        'go.work',
        'go.mod',
        '.git',
    },

    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                unusedwrite = true,
                nilness = true,
            },

            staticcheck = true,
            semanticTokens = true,
            usePlaceholders = true,
            gofumpt = true,

            directoryFilters = {
                '-.git',
                '-.vscode',
                '-.idea',
                '-.vscode-test',
                '-node_modules',
            },

            codelenses = {
                test = true,
            },
        },
    },
}
