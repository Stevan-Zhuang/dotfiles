return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    -- enabled = false,
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
      { "nvim-telescope/telescope.nvim" }, -- for telescope help actions (optional)
    },
    opts = {
      model = "gpt-4", -- GPT model to use
      temperature = 0.1, -- GPT temperature
      debug = false, -- Enable debug logging
      show_user_selection = true, -- Shows user selection in chat
      show_system_prompt = false, -- Shows system prompt in chat
      show_folds = true, -- Shows folds for sections in chat
      clear_chat_on_new_prompt = false, -- Clears chat on every new prompt
      auto_follow_cursor = true, -- Auto-follow cursor in chat
      name = "CopilotChat", -- Name to use in chat
      separator = "---", -- Separator to use in chat
      window = {
        layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
        -- Options below only apply to floating windows
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = nil, -- row position of the window, default is centered
        col = nil, -- column position of the window, default is centered
        title = 'Copilot Chat', -- title of chat window
        footer = nil, -- footer of chat window
        zindex = 1, -- determines if window is on top or below other floating windows
      },
      mappings = {
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-m>",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        yank_diff = {
          normal = "gy",
        },
        show_diff = {
          normal = "gd",
        },
        show_system_prompt = {
          normal = "gp",
        },
        show_user_selection = {
          normal = "gs",
        },
      },
    },

    config = function(_, opts)
      local select = require "CopilotChat.select"

      opts.selection = function(source)
        local startPos = vim.fn.getpos "'<"
        local endPos = vim.fn.getpos "'>"
        local startLine, startCol = startPos[2], startPos[3]
        local endLine, endCol = endPos[2], endPos[3]

        if startLine ~= endLine or startCol ~= endCol then
          return select.visual(source)
        else
          return select.buffer(source)
        end
      end

      local prompts = {
        QuickChat = { selection = select.unnamed },
        RegisterChat = { selection = select.unnamed },
        BufferChat = { selection = select.buffer },
        Explain = { selection = select.unnamed, prompt = "Explain how the code works." },
        FixError = {
          selection = select.unnamed,
          prompt = "please explain the errors in the text above and provide a solution.",
        },
        Suggestion = {
          selection = select.unnamed,
          prompt = "Please review the code above and provide suggestions for improvement.",
        },
        Refactor = {
          selection = select.unnamed,
          prompt = "Please refactor the following code to improve its clarity and readability.",
        },
        Tests = {
          selection = select.unnamed,
          prompt = "Briefly explain how the selected code works and then generate a unit test.",
        },
        Annotations = { selection = select.unnamed, prompt = "Add comments to the above code" },

        FixDiagnostic = {
          prompt = "Please assist with the following diagnostic issue in file:",
          selection = select.diagnostics,
        },
        Commit = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          selection = select.gitdiff,
        },
        CommitStaged = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          selection = function(source) return select.gitdiff(source, true) end,
        },
      }
      opts.prompts = prompts
      require("CopilotChat").setup(opts)

      local options = {
        "QuickChat",
        "RegisterChat",
        "BufferChat",
        "Explain",
        "FixError",
        "Suggestion",
        "Refactor",
        "Tests",
        "Annotations",
        "FixDiagnostic",
        "Commit",
        "CommitStaged",
      }

      local pickers = require "telescope.pickers"
      local finders = require "telescope.finders"
      local conf = require("telescope.config").values
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      local Chat_prompts = require("CopilotChat").prompts()

      local Telescope_CopilotActions = function(opts)
        opts = opts or {}
        pickers
          .new(opts, {
            prompt_title = "Select Copilot prompt",
            finder = finders.new_table { results = options },
            sorter = conf.generic_sorter(opts),

            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selected = action_state.get_selected_entry()
                local choice = selected[1]
                local msg = ""
                local selection = nil
                -- Find the item message and selection base on the choice
                for item, body in pairs(Chat_prompts) do
                  if item == choice then
                    msg = body.prompt
                    selection = body.selection
                    break
                  end
                end
                if choice == "QuickChat" then selection = function() return nil end end

                require("CopilotChat").ask(msg, { selection = selection })
              end)
              return true
            end,
          })
          :find()
      end

      vim.api.nvim_create_user_command(
        "CopilotActions",
        function() Telescope_CopilotActions(require("telescope.themes").get_dropdown {}) end,
        { nargs = "*", range = true }
      )
    end,

    keys = {
      {
        "<leader>a",
        function()
          -- require("CopilotChat.code_actions").show_prompt_actions()
          vim.cmd "CopilotActions"
        end,
        desc = " Prompt actions",
        mode = { "n", "v", "x" },
      },
    },
  },
}
