return  {
  'neovim/nvim-lspconfig',
   event = { "BufReadPre", "BufNewFile" },
   dependencies = {
    { 'williamboman/mason.nvim', config = true, cmd = "Mason" },
    'williamboman/mason-lspconfig.nvim',
    { 'j-hui/fidget.nvim', config = true },
    { 'folke/neodev.nvim', config = true },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace [L]ist Folders')
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_) vim.lsp.buf.format() end, { desc = 'Format current buffer with LSP' })
      vim.keymap.set('n', '<Leader>f', ":Format<cr>")
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
      ensure_installed = {"clangd","gopls"} 
    }
    local nvim_lsp = require('lspconfig')
    mason_lspconfig.setup_handlers{
        function(server_name)
            local opts = {}
            opts.on_attach = function(_, buffnr)
                local bufopts = {silent = true, noremap = true}
                vim.api.nvim_buf_set_keymap(buffnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', bufopts)
                vim.api.nvim_buf_set_keymap(buffnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopts)
            opts.capabilities = capabilities;
        end
        nvim_lsp[server_name].setup(opts)
    end
  }
  end
}

