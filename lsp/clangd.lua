return {
    root_markers = { 'compile_commands.json', 'build/compile_commands.json' },
    filetypes = { 'c', 'cpp' },
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
