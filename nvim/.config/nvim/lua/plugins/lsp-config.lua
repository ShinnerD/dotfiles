return {
  {
    -- Java + Spring Boot. Manages jdtls itself, so it is NOT in ensure_installed.
    "nvim-java/nvim-java",
    lazy = false,
    config = function()
      require("java").setup()
      vim.lsp.enable("jdtls")
    end,
  },
  {
    "mason-org/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    -- Installs the servers below and calls vim.lsp.enable() for each one.
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "gradle_ls",     -- build.gradle (Groovy DSL)
        "yamlls",        -- YAML (Spring config, k8s, CI)
        "lemminx",       -- XML
        "regal",         -- Rego / OPA
        "basedpyright",  -- Python types/completion
        "ruff",          -- Python lint + format
        "lua_ls",        -- your nvim config
        "jsonls",        -- JSON
        "bashls",        -- shell scripts
        "dockerls",      -- Dockerfiles
      },
      -- jdtls is started by nvim-java, not here
      automatic_enable = { exclude = { "jdtls" } },
    },
  },
  {
    -- Provides the server configs (cmd, filetypes, root markers) for vim.lsp.config.
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim", -- JSON/YAML schemas
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- YAML: use SchemaStore instead of yamlls' built-in fetching
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Let ruff do linting/formatting; pyright for types only
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          map("K",          vim.lsp.buf.hover,           "Hover")
          map("<leader>ld", vim.lsp.buf.definition,      "Definition")
          map("<leader>lr", vim.lsp.buf.references,      "References")
          map("<leader>li", vim.lsp.buf.implementation,  "Implementation")
          map("<leader>lt", vim.lsp.buf.type_definition, "Type Definition")
          map("<leader>la", vim.lsp.buf.code_action,     "Code Action")
          map("<leader>ln", vim.lsp.buf.rename,          "Rename")
          map("<leader>lf", vim.lsp.buf.format,          "Format")
          map("<leader>le", vim.diagnostic.open_float,   "Line Diagnostics")
        end,
      })
    end,
  },
}
