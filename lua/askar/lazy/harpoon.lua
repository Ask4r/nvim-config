return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
        local harpoon = require "harpoon"
        harpoon:setup()

        vim.keymap.set("n", "<leader>hl", function()
            harpoon:list():add()
        end)
        vim.keymap.set("n", "<leader>hm", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end)

        -- Set <leader>1..<leader>5 be my shortcuts to moving to the files
        for _, idx in ipairs { 1, 2, 3, 4, 5 } do
            vim.keymap.set("n", string.format("<leader>%d", idx), function()
                harpoon:list():select(idx)
            end)
        end
    end,
}
