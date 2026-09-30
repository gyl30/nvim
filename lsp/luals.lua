return {
    cmd = { 'lua-language-server' },

    filetypes = { 'lua' },

    root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git',
    },

    on_init = function(client)
        local path = client.workspace_folders
            and client.workspace_folders[1]
            and client.workspace_folders[1].name

        if path
            and path ~= vim.fn.stdpath('config')
            and (
                vim.uv.fs_stat(path .. '/.luarc.json')
                or vim.uv.fs_stat(path .. '/.luarc.jsonc')
            )
        then
            return
        end

        client.config.settings.Lua = vim.tbl_deep_extend(
            'force',
            client.config.settings.Lua,
            {
                runtime = {
                    version = 'LuaJIT',
                    path = {
                        'lua/?.lua',
                        'lua/?/init.lua',
                    },
                },

                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        '${3rd}/luv/library',
                    },
                },
            }
        )
    end,

    settings = {
        Lua = {
            telemetry = {
                enable = false,
            },

            runtime = {
                special = {
                    reload = 'require',
                },
            },

            diagnostics = {
                globals = {
                    'vim',
                    'reload',
                },
            },

            completion = {
                callSnippet = 'Replace',
            },
        },
    },
}
