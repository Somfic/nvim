return {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'NvimTreeToggle',
    keys = {
        { '<leader>vf', ':NvimTreeToggle<CR>', desc = 'Toggle file explorer (view files)' },
    },
    config = function()
        require('nvim-tree').setup {
            actions = {
                open_file = {
                    quit_on_open = true,
                    window_picker = {
                        enable = false, -- Ensures it replaces the current buffer
                    },
                },
            },
        }
    end,
}
