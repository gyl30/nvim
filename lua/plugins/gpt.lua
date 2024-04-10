return {
    'skywind3000/vim-gpt-commit',
    config = function()
        vim.g.gpt_commit_concise = 1
        vim.g.gpt_commit_staged = 1

        -- vim.g.gpt_commit_key = os.getenv("OPENAI_API_KEY")
        -- vim.g.gpt_commit_proxy = 'https://127.0.0.1:8889'
        vim.g.gpt_commit_engine = 'ollama'
        vim.g.gpt_commit_ollama_url = 'http://127.0.0.1:11434/api/chat'
        vim.g.gpt_commit_ollama_model = 'llama2'
    end,
}
