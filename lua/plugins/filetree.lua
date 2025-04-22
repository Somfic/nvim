return {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'NvimTreeToggle',
    keys = {
        { '<leader>vf', ':NvimTreeToggle<CR>', desc = 'Toggle file explorer (view files)' },
    },
    config = function()
        require('nvim-tree').setup {
            view = { side = 'right', width = 30 },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
            },
        }
    end,
}
