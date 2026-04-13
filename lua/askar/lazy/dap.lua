local curr_dirname = function()
    return string.match(vim.fn.getcwd(), ".*/([%w-_]+)")
end

local zig_exe_path = function()
    return vim.fn.getcwd() .. "/zig-out/bin/" .. curr_dirname()
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "leoluz/nvim-dap-go",
        "nicholasmata/nvim-dap-cs",
        "mfussenegger/nvim-dap-python",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-neotest/nvim-nio",
        "williamboman/mason.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local mason_bin_dir = vim.fn.stdpath("data") .. "/mason/bin"

        require("dapui").setup()
        require("dap-go").setup()
        require("dap-cs").setup({
            netcoredbg = {
                path = mason_bin_dir .. "/netcoredbg",
            },
        })
        require("dap-python").setup("python3")

        require("nvim-dap-virtual-text").setup({
            -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
            display_callback = function(variable)
                local name = string.lower(variable.name)
                local value = string.lower(variable.value)
                if name:match "secret" or name:match "api" or value:match "secret" or value:match "api" then
                    return "*****"
                end

                if #variable.value > 15 then
                    return " " .. string.sub(variable.value, 1, 15) .. "... "
                end

                return " " .. variable.value
            end,
        })

        -- Handled by nvim-dap-go
        -- dap.adapters.go = {
        --     type = "server",
        --     port = "${port}",
        --     executable = {
        --         command = "dlv",
        --         args = { "dap", "-l", "127.0.0.1:${port}" },
        --     },
        -- }

        local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")
        if elixir_ls_debugger ~= "" then
            dap.adapters.mix_task = {
                type = "executable",
                command = elixir_ls_debugger,
            }

            dap.configurations.elixir = {
                {
                    type = "mix_task",
                    name = "phoenix server",
                    task = "phx.server",
                    request = "launch",
                    projectDir = "${workspaceFolder}",
                    exitAfterTaskReturns = false,
                    debugAutoInterpretAllModules = false,
                },
            }
        end


        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
        }
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = mason_bin_dir .. "/codelldb", -- I installed codelldb through mason.nvim
                args = { "--port", "${port}" },
            },
        }
        -- dap.adapters.debugpy = {
        --     type = "server",
        --     port = "${port}",
        --     executable = {
        --         command = mason_bin_dir .. "/debugpy",
        --         args = { "--listen", ":${port}" },
        --     },
        -- }


        dap.configurations.c = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            }
        }
        dap.configurations.zig = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = zig_exe_path,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }
        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }
        -- dap.configurations.python = {
        --     {
        --         name = "Launch",
        --         type = "debugpy",
        --         request = "launch",
        --         program = python_file_path,
        --         cwd = "${workspaceFolder}",
        --         stopOnEntry = false,
        --     },
        -- }


        vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint)
        vim.keymap.set("n", "<leader>gb", dap.run_to_cursor)

        -- Eval var under cursor
        vim.keymap.set("n", "<leader>?", function()
            require("dapui").eval(nil, { enter = true })
        end)

        vim.keymap.set("n", "<leader>dc", dap.continue)
        vim.keymap.set("n", "<C-[>", dap.step_into)
        vim.keymap.set("n", "<C-]>", dap.step_over)
        vim.keymap.set("n", "<leader>do", dap.step_out)
        vim.keymap.set("n", "<leader>db", dap.step_back)
        vim.keymap.set("n", "<leader>dr", dap.restart)

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
}
