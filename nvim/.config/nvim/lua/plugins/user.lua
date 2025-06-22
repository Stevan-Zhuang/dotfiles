-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {}
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = false,
      integrations = {
        alpha = true,
        aerial = true,
        dap = true,
        dap_ui = true,
        mason = true,
        neotree = true,
        notify = true,
        nvimtree = false,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = true,
        ts_rainbow = false,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay0 },
        }
      end,
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    init = function() require("todo-comments").setup() end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "User AstroFile",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 150,
        keymap = {
          accept = "<C-f>",
          dismiss = "<C-x>",
          next = "<M-n>",
          prev = "<M-p>",
        },
      },
      filetypes = {
        markdown = true
      }
    }
  },
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
          last_active = "<C-\\>",
          next = "<C-Space>",
        },
      }
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    opts = {
      indent = {
        char = "│",
      },
      scope = {
        enabled = false,
      },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "Trouble", "lazy", "neo-tree" },
      },
      whitespace = {
        remove_blankline_trail = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "BufReadPre",
    config = function()
      require("lualine").setup {
        options = {
          theme = "catppuccin",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
      }
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    init = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = "sioyek"
      vim.g.vimtex_quickfix_mode = 0
      vim.opt.conceallevel = 2
      vim.g.tex_conceal = "abdmg"
      vim.g.vimtex_syntax_enabled = 1
    end,
  },
  {
    "frabjous/knap",
    init = function()
      local gknapsettings = {
        mdoutputext = "pdf"
      }
      vim.g.knap_settings = gknapsettings
      -- set shorter name for keymap function
      local kmap = vim.keymap.set

      -- F5 processes the document once, and refreshes the view
      kmap({ 'n', 'v' },'<leader>ka', function() require("knap").process_once() end)

      -- F6 closes the viewer application, and allows settings to be reset
      kmap({ 'n', 'v' },'<leader>ks', function() require("knap").close_viewer() end)

      -- F7 toggles the autcessing on and off
      kmap({ 'n', 'v' },'<leader>kd', function() require("knap").toggle_autopreviewing() end)

      -- F8 invokes a SyncTrward search, or similar, where appropriate
      kmap({ 'n', 'v' },'<leader>kf', function() require("knap").forward_jump() end)
    end,
  },
  {
    "AckslD/swenv.nvim",
    init = function()
      local swenv = require('swenv.api')
      swenv.set_venv('base')
      swenv.auto_venv()
    end,
    keys = {
      {
        "<leader>vv",
        function()
          require('swenv.api').pick_venv()
        end,
        desc = "Pick virtual environment",
        mode = { "n", "v", "x" },
      },
    }
  }
}
