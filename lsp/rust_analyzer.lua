return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },

    root_dir = function(bufnr, cb)
        local root = vim.fs.root(bufnr, { 'Cargo.toml' })

        if root then
            vim.system(
                {
                    'cargo',
                    'metadata',
                    '--no-deps',
                    '--format-version',
                    '1',
                },
                { cwd = root },
                function(obj)
                    if obj.code ~= 0 then
                        cb(root)
                        return
                    end

                    local success, result =
                        pcall(vim.json.decode, obj.stdout)

                    if success and result.workspace_root then
                        cb(result.workspace_root)
                    else
                        cb(root)
                    end
                end
            )
        else
            cb(vim.fs.root(bufnr, {
                'rust-project.json',
                '.git',
            }))
        end
    end,
}
