return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({
            notification = {
                window = {
                    winblend = 0
                }
            }
        })

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "gopls",
                "clangd",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["clangd"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.clangd.setup {
                        capabilities = capabilities,
                        cmd = {
                            "clangd",
                            "--experimental-modules-support",
                        },
                        filetypes = { "c", "cpp", "h", "cppm", "cc", "mpp", "ixx", "tpp" },
                        init_options = {
                            fallbackFlags = { "--std=c++20" }
                        },
                    }
                end,
            }
        })

        -- Custom servers

        -- local lspconfig = require("lspconfig")
        -- local mason_bin_dir = vim.fn.stdpath("data") .. "/mason/bin"
        --
        -- lspconfig.postgres_lsp.setup {
        --     capabilities = capabilities,
        --     cmd = { mason_bin_dir .. "/postgres-language-server", "lsp-proxy" },
        --     filetypes = { "sql" },
        --     root_markers = { "postgres-language-server.jsonc" },
        --     workspace_required = true,
        --     on_attach = function(client, bufnr)
        --         vim.keymap.del('i', '<C-C>a', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>L', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>l', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>c', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>v', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>p', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>t', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>s', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>o', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>f', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>k', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>R', { buffer = bufnr })
        --         vim.keymap.del('i', '<C-C>T', { buffer = bufnr })
        --     end,
        -- }


        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
