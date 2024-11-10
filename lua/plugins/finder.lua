return {
  {
    "nvim-telescope/telescope.nvim",
    name = "telescope",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', 'fc', builtin.live_grep, {})
      vim.keymap.set('n', 'ff', builtin.find_files, {})
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {

            }
          }
        }
      })

      require('telescope').load_extension('ui-select')
    end
  },
  {
    "jvgrootveld/telescope-zoxide",
    config = function()
      local t = require("telescope")
      local z_utils = require("telescope._extensions.zoxide.utils")

      t.setup({
        extensions = {
          zoxide = {
            prompt_title = " Find Project ",
            mappings = {
              default = {
                after_action = function(selection)
                  print("Update to (" .. selection.z_score .. ") " .. selection.path)
                end
              },
              ["<C-s>"] = {
                before_action = function(selection) print("before C-s") end,
                action = function(selection)
                  vim.cmd.edit(selection.path)
                end
              },
              ["<C-q>"] = { action = z_utils.create_basic_command("split") },
            },
          },
        },
      })

      -- Load the extension
      t.load_extension('zoxide')

      -- Add a mapping
      vim.keymap.set("n", "cd", t.extensions.zoxide.list)
    end
  }
}
