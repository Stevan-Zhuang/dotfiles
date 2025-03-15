return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
    keys = {
      {
        "<leader>a",
        function()
          local chat = require("CopilotChat")
          chat.toggle({selection = false})
        end,
        desc = "Copilot QuickChat",
        mode = { "n", "v", "x" },
      },
      {
        "<leader>A",
        function()
          local chat = require("CopilotChat")
          chat.toggle()
        end,
        desc = "Copilot Chat",
        mode = { "n", "v", "x" },
      },
    },
  },
}
