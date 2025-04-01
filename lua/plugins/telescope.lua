return
{
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'jvgrootveld/telescope-zoxide' },
        { 'nvim-tree/nvim-web-devicons' }
    },
    config = function()
        local telescope = require 'telescope'

        telescope.setup {
            extensions = {
                ['ui-select'] = { require('telescope.themes').get_dropdown() },
                ['fzf'] = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = 'smart_case',
                },
                ['zoxide'] = {
                    prompt_title = "directories",
                    mappings = {
                        default = {
                            after_action = function(selection)
                                print("Update to (" .. selection.z_score .. ") " .. selection.path)
                            end
                        },
                    },
                },
            },
        }
        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'ui-select')
        pcall(telescope.load_extension, 'zoxide')
        pcall(telescope.load_extension, 'projects')

        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>fd', telescope.extensions.zoxide.list, { desc = 'directories' })
        vim.keymap.set('n', '<leader>ff', builtin.git_files, { desc = 'files' })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'recent files' })

        vim.keymap.set('n', '<leader>fh', builtin.current_buffer_fuzzy_find, { desc = 'code in file' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'code globally' })

        vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'branches' })
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'commits' })
        vim.keymap.set('n', '<leader>gl', builtin.git_commits, { desc = 'logs' })
        vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'status' })
    end,
}
