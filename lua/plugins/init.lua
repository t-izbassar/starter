return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "kotlin",
        "scala",
        "rust",
      },
    },
  },

  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "j-hui/fidget.nvim",
        opts = {},
      },
      {
        "mfussenegger/nvim-dap",
        config = function(_, _)
          local dap = require "dap"

          dap.configurations.scala = {
            {
              type = "scala",
              request = "launch",
              name = "RunOrTest",
              metals = {
                runType = "runOrTestFile",
              },
            },
            {
              type = "scala",
              request = "launch",
              name = "Test Target",
              metals = {
                runType = "testTarget",
              },
            },
          }
        end,
      },
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()

      metals_config.settings = {
        showImplicitArguments = true,
      }

      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

      metals_config.on_attach = function(_, bufnr)
        require("metals").setup_dap()

        -- your on_attach function
        local function opts(desc)
          return { buffer = bufnr, desc = "LSP " .. desc }
        end

        local map = vim.keymap.set
        map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
        map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
        map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

        map("n", "<leader>ws", function()
          require("metals").hover_worksheet()
        end, opts "Metals hover worksheet")

        map("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts "List workspace folders")

        map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")

        map("n", "<leader>ra", function()
          require "nvchad.lsp.renamer"()
        end, opts "NvRenamer")

        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
        map("n", "gr", vim.lsp.buf.references, opts "Show references")
        map("n", "gds", vim.lsp.buf.document_symbol, opts "Document symbol")
        map("n", "gws", vim.lsp.buf.workspace_symbol, opts "Workspace symbol")

        map("n", "<leader>aa", vim.diagnostic.setqflist, opts "All workspace diagnostics")
        map("n", "<leader>ae", function()
          vim.diagnostic.setqflist { severity = "ERROR" }
        end, opts "All workspace errors")

        map("n", "<leader>aw", function()
          vim.diagnostic.setqflist { severity = "WARN" }
        end, opts "All workspace warnings")

        map("n", "<leader>d", vim.diagnostic.setloclist, opts "Buffer diagnostics only")

        map("n", "[c", function()
          vim.diagnostic.goto_prev { wrap = false }
        end, opts "Go to previous diagnostic in current buffer")

        map("n", "]c", function()
          vim.diagnostic.goto_next { wrap = false }
        end, opts "Go to next diagnostic in current buffer")

        map("n", "<leader>fl", vim.lsp.buf.format, opts "Format using lsp")

        -- DAP mappings with descriptions
        map("n", "<leader>dc", function()
          require("dap").continue()
        end, opts "Continue debugging")

        map("n", "<leader>dr", function()
          require("dap").repl.toggle()
        end, opts "Toggle REPL")

        map("n", "<leader>dK", function()
          require("dap.ui.widgets").hover()
        end, opts "Hover")

        map("n", "<leader>dt", function()
          require("dap").toggle_breakpoint()
        end, opts "Toggle breakpoint")

        map("n", "<leader>dso", function()
          require("dap").step_over()
        end, opts "Step over")

        map("n", "<leader>dsi", function()
          require("dap").step_into()
        end, opts "Step into")

        map("n", "<leader>dl", function()
          require("dap").run_last()
        end, opts "Run last")
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
}
