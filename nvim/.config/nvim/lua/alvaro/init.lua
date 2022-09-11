-- An alias easier to type
function inspect(...)
    print(vim.inspect(...))
end

-- Show the current clients attached the the
function buf_show_clients()
    print(vim.inspect(vim.lsp.buf_get_clients()))
end
