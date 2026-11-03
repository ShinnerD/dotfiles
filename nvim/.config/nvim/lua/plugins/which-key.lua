return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = {
      -- Groups (these are the labels shown in the popup)
      { "<leader>f", group = "Find / Files" },
      { "<leader>b", group = "Buffers" },
      { "<leader>s", group = "Search" },
      { "<leader>j", group = "Java" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "LSP" },
      { "<leader>x", group = "Diagnostics" },
      { "<leader>u", group = "UI Toggles" },

      -- Find / Files 
      { "<leader>ff",            function() Snacks.picker.pick("files") end, desc = "Find Files" },
      { "<leader><leader>", function() Snacks.picker.recent() end,      desc = "Recent Files" },
      { "<leader>fg",       function() Snacks.picker.grep() end,        desc = "Grep Files" },
      { "<leader>ft", function() Snacks.explorer() end,        desc = "File Tree" },
      { "<leader>fr", function() Snacks.explorer.reveal() end, desc = "Reveal Current File" },

      -- Buffers
      { "<leader>bb", function() Snacks.picker.buffers() end,   desc = "Pick Buffer" },
      { "<leader>bd", function() Snacks.bufdelete() end,        desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end,  desc = "Delete Other Buffers" },
      { "<leader>bA", function() Snacks.bufdelete.all() end,    desc = "Delete All Buffers" },
      { "<leader>bl", "<cmd>b#<cr>",                            desc = "Last Buffer" },
      { "<leader>bn", "<cmd>bnext<cr>",                         desc = "Next Buffer" },
      { "<leader>bp", "<cmd>bprevious<cr>",                     desc = "Previous Buffer" },

      -- Dashboard
      { "<leader>D", function() Snacks.dashboard() end, desc = "Dashboard" },

      -- Search
      { "<leader>sk", function() Snacks.picker.keymaps() end,         desc = "Keymaps" },
      { "<leader>sh", function() Snacks.picker.help() end,            desc = "Help Pages" },
      { "<leader>sc", function() Snacks.picker.commands() end,        desc = "Commands" },
      { "<leader>sr", function() Snacks.picker.resume() end,          desc = "Resume Last Search" },
      { "<leader>su", function() Snacks.picker.undo() end,            desc = "Undo History" },
      { "<leader>sw", function() Snacks.picker.grep_word() end,       desc = "Grep Word", mode = { "n", "x" } },
      { "<leader>sl", function() Snacks.picker.lines() end,           desc = "Lines in Buffer" },

      -- Java (nvim-java commands)
      { "<leader>jt", "<cmd>JavaTestRunCurrentMethod<cr>",    desc = "Test Method" },
      { "<leader>jT", "<cmd>JavaTestRunCurrentClass<cr>",     desc = "Test Class" },
      { "<leader>jd", "<cmd>JavaTestDebugCurrentMethod<cr>",  desc = "Debug Test Method" },
      { "<leader>jv", "<cmd>JavaRefactorExtractVariable<cr>", desc = "Extract Variable", mode = { "n", "v" } },
      { "<leader>jm", "<cmd>JavaRefactorExtractMethod<cr>",   desc = "Extract Method",   mode = { "n", "v" } },
      { "<leader>jr", function() Snacks.terminal("./gradlew bootRun") end, desc = "Gradle bootRun" },
      { "<leader>jC", function() Snacks.terminal("./gradlew check") end,    desc = "Gradle check" },

      -- Git
      { "<leader>gg", function() Snacks.lazygit() end,          desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log_file() end, desc = "Lazygit Log (file)" },
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Branches" },
      { "<leader>gs", function() Snacks.picker.git_status() end,   desc = "Status" },
      { "<leader>gB", function() Snacks.gitbrowse() end,           desc = "Open in Browser", mode = { "n", "v" } },

      -- LSP
      { "<leader>ls", function() Snacks.picker.lsp_symbols() end,           desc = "Document Symbols" },
      { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
      { "<leader>l=", "gg=G``", desc = "Re-indent File" },
      {
        "<leader>lo",
        function()
          vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
        end,
        desc = "Organize Imports",
      },
      
      -- Diagnostics
      { "<leader>xx", function() Snacks.picker.diagnostics() end,        desc = "Workspace Diagnostics" },
      { "<leader>xb", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>xq", function() Snacks.picker.qflist() end,             desc = "Quickfix List" },

      -- Terminal
      { "<leader>T", function() Snacks.terminal() end, desc = "Terminal", mode = { "n", "t" } },

      -- Scratch
      { "<leader>.", function() Snacks.scratch() end,        desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },

      -- UI (other mappings in snacks.lua)
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },

      -- Windows
      { "<leader>w", proxy = "<c-w>", group = "Windows" },

      -- Which-key 
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Local Keymaps",
      },
    },
  },
}
