return {
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    single_file_support = true,
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    cmd = {
        'clangd',
        '-j=8',
        '--function-arg-placeholders=0',
    },
}
