return {
    'echasnovski/mini.nvim',
    branch = "v3.x",
    lazy = false,
    config = function()
        require('mini.files').setup()
    end
}
