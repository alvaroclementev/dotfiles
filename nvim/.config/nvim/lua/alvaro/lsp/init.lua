local status, lspconfig = pcall(require, 'lspconfig')
if (not status) then return end

-- NOTE: The pacakges are installed at `vim.fn.stdpath("data") / "mason"` which
-- points to: `$HOME/.local/share/nvim/mason`
require('mason').setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        }
    },
    log_level = vim.log.levels.INFO, -- Set to DEBUG when debugging issues
}
require('mason-lspconfig').setup()
vim.lsp.set_log_level('warn')

-- Setup lspsaga
local lspsaga_status, lspsaga = pcall(require, 'lspsaga')
if lspsaga_status then
    require('lspsaga').init_lsp_saga {
        code_action_lightbulb = {
            enable = false,
        }
    }
end


-- NOTE(alvaro): Since lspsaga v0.2 it requires mappings to use
-- `<cmd>` based rhs for `vim.keymap.set`
-- Setup the common options (completion, diagnostics, keymaps)
local on_attach_general = function(client)
    -- Mappings
    local opts = { silent = true, buffer = 0 }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gI', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gk', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, opts)
    vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, opts)
    -- vim.keymap.set('n', '<LocalLeader>rn', vim.lsp.buf.rename, opts)
    -- vim.keymap.set('n', '<LocalLeader>ca', vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('i', '<C-H>', vim.lsp.buf.signature_help, opts)

    -- LSPSaga related mappings
    if lspsaga_status then
        print('setting the lspsaga keymaps')
        vim.keymap.set('n', '<LocalLeader>ca', '<cmd>Lspsaga code_action<CR>', opts)
        vim.keymap.set('v', '<LocalLeader>ca', '<cmd><C-U>Lspsaga range_code_action<CR>', opts)
        vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
        -- FIXME(alvaro): update these mappings, although they may just work
        vim.keymap.set('n', '<C-f>', function()
            require('lspsaga.action').smart_scroll_with_saga(1)
        end, opts)
        vim.keymap.set('n', '<C-b>', function()
            require('lspsaga.action').smart_scroll_with_saga(-1)
        end, opts)
        vim.keymap.set('n', 'gh', '<cmd>Lspsaga signature_help<CR>', opts)
        vim.keymap.set('i', '<C-H>', '<cmd>Lspsaga signature_help<CR>', opts)
        vim.keymap.set('n', '<LocalLeader>rn', '<cmd>Lspsaga rename<CR>', opts)
        vim.keymap.set('n', 'gp', '<cmd>Lspsaga preview_definition<CR>', opts)
    end

    -- Others
    -- TODO(alvaro): Do this all in a custom command in lua, now is a bit flickery
    vim.keymap.set('n', 'gs', ':vsp<CR><cmd>lua vim.lsp.buf.definition()<CR>zz', opts)
    vim.keymap.set('n', 'gx', ':sp<CR><cmd>lua vim.lsp.buf.definition()<CR>zz', opts)

    -- Formatting (Conditional to Capabilities)
    if client.server_capabilities.documentFormattingProvider then
        vim.keymap.set('n', '<LocalLeader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
        -- TODO(alvaro): Is this necessary anymore?
        vim.keymap.set('x', '<LocalLeader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    elseif client.server_capabilities.documentRangeFormattingProvider then
        vim.keymap.set('n', '<LocalLeader>f', vim.lsp.buf.range_formatting, opts)
    else
        print("No formatting capabilities reported")
    end
end

-- Update the capabilities as suggested by `cmp-nvim-lsp`
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- sumneko_lua
-- TODO(alvaro): Make lua ignore plugins that we don't control
lspconfig.sumneko_lua.setup {
    -- Lua LSP configuration (inspired by the one in tjdevries/nlua.nvim
    on_attach = on_attach_general,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                -- TODO(alvaro): Review this
                path = vim.split(package.path, ";"),
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                -- TODO(alvaro): test the alternative:
                -- library = vim.api.nvim_get_runtime_file("", true)
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/lsp"),
                },
                ignoreDir = {
                    -- FIXME(alvaro): Make sure we only diagnose the right files
                    vim.fn.stdpath("config") .. "/plugged",
                }
            },
            telemetry = {
                enable = false
            },
        }
    },
    capabilities = capabilities,
}

-- pylsp
lspconfig.pylsp.setup {
    on_attach = on_attach_general,
    settings = {
        pylsp = {
            configurationSources = { 'flake8' },
            plugins = {
                jedi = {
                    extra_paths = {
                        "./src",
                        "./src/daimler/mltoolbox"
                    },
                },
                jedi_completion = {
                    enabled = true,
                    fuzzy = false,
                },
                jedi_definition = {
                    enabled = true,
                },
                black = {
                    enabled = true,
                },
                isort = {
                    enabled = true,
                },
                flake8 = {
                    enabled = true,
                },
                -- Temporarily disable these globally (should be per-project)
                -- TODO(alvaro): Make this work so we can remove the awful
                -- `pylsp-mypy.cfg` file
                pyls_mypy = {
                    enabled = false,
                    live_mode = true,
                },
                -- Disable these plugins explicitly
                pycodestyle = {
                    enabled = false,
                },
                pylint = {
                    enabled = false,
                },
                mccabe = {
                    enabled = false,
                },
                autopep8 = {
                    enabled = false,
                },
                pydocstyle = {
                    enabled = false,
                },
                pyflakes = {
                    enabled = false,
                },
            }
        }
    },
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
}

-- vimls
lspconfig.vimls.setup {
    on_attach = on_attach_general,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
}


-- TODO(alvaro): vuels (vetur) works for vue 2, for Vue 3 use `volar`
-- vuels
lspconfig.vuels.setup {
    on_attach = on_attach_general,
    settings = {
        javascript = {
            format = {
                enable = true,
            }
        },
        vetur = {
            ignoreProjectWarning = true,
            format = {
                enable = true,
                defaultFormatter = {
                    js = "prettier",
                    html = "prettier",
                    css = "prettier",
                }
            }
        }
    },
    capabilities = capabilities,
}

-- lspconfig.volar.setup {
-- TODO(alvaro): See if this is what we want? This is for "Take Over Mode"
-- filetypes = {"typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json"}
-- on_attach = on_attach_general,
-- capabilities=capabilities,
-- }

-- Rust
local rust_status, rt = pcall(require, 'rust-tools')
if rust_status then
    rt.setup {
        tools = {
            executor = require('rust-tools/executors').termopen,
            reload_workspace_from_cargo_toml = true,
            inlay_hints = {
                only_current_line = true,
                show_parameter_hints = true,
                -- TODO(alvaro): Test these
                -- parameter_hints_prefix = "",  -- default is ="<- "
                -- other_hints_prefix = "",  -- default is "=> "
                -- TODO(alvaro): You can also right align
                max_len_align = true,
                max_len_align_padding = 1,
                highlight = "Commend",
            },
            -- FIXME(alvaro): This is throwing a deprecated error
            -- hover_with_actions = true,
        },
        -- These options are passed to `nvim-lspconfig`
        server = {
            on_attach = on_attach_general,
            flags = {
                debounce_text_changes = 150,
            },
            settings = {
                ["rust-analyzer"] = {
                    -- enable clippy on save
                    checkOnSave = {
                        command = "clippy",
                    }
                }
            },
            -- Standalone file support
            -- setting it to false may improve startup time
            standalone = false,
        },
        -- debugging stuff
        -- FIXME(alvaro): Unused and untested for now
        dap = {
            adapter = {
                type = "executable",
                command = "lldb-vscode",
                name = "rt_lldb",
            }
        },
        capabilities = capabilities,
    }
end
