-- lua/plugins/debugging.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text", -- Montrer les valeurs dans le code
      "nvim-telescope/telescope-dap.nvim", -- Integration Telescope
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      -- Configuration de dap-ui
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "↩",
            run_last = "↺",
            terminate = "□",
          },
        },
      })

      -- Ouvrir/fermer dapui automatiquement
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Configuration de nvim-dap-virtual-text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
      })

      -- Configuration pour Python
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            -- Détecte automatiquement l'environnement Python actif
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
          end,
        },
      }

      -- Configuration pour C/C++/Rust avec LLDB
      -- Vérifier différentes possibilités de chemins pour lldb-vscode
      local lldb_paths = {
        "/usr/bin/lldb-vscode",
        "/usr/local/bin/lldb-vscode",
        "/opt/homebrew/bin/lldb-vscode",
        "/usr/lib/llvm-*/bin/lldb-vscode", -- Pour les distributions basées sur Debian/Ubuntu
      }
      
      local lldb_command = nil
      for _, path in ipairs(lldb_paths) do
        -- Gère les chemins avec wildcard
        if path:find("*") then
          local possible_paths = vim.fn.glob(path, false, true)
          for _, p in ipairs(possible_paths) do
            if vim.fn.executable(p) == 1 then
              lldb_command = p
              break
            end
          end
        elseif vim.fn.executable(path) == 1 then
          lldb_command = path
          break
        end
      end
      
      if lldb_command then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_command,
          name = "lldb",
        }
        
        local lldb_config = {
          {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
          },
        }
        
        dap.configurations.cpp = lldb_config
        dap.configurations.c = lldb_config
        dap.configurations.rust = vim.deepcopy(lldb_config)
        
        -- Ajout spécifique pour Rust: utilisation de cargo
        dap.configurations.rust[2] = {
          name = "Launch Rust (cargo)",
          type = "lldb",
          request = "launch",
          program = function()
            local metadata_cmd = "cargo metadata --format-version 1"
            local metadata_str = vim.fn.system(metadata_cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Failed to run cargo metadata", vim.log.levels.ERROR)
              return ""
            end
            local ok, metadata = pcall(vim.fn.json_decode, metadata_str)
            if not ok or not metadata or not metadata.packages or #metadata.packages == 0 then
              vim.notify("Failed to parse cargo metadata", vim.log.levels.ERROR)
              return ""
            end
            local target_dir = metadata.target_directory
            local binary_name = metadata.packages[1].targets[1].name
            return target_dir .. "/debug/" .. binary_name
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        }
      else
        vim.notify("LLDB adapter (lldb-vscode) non trouvé. Veuillez l'installer pour le débogage C/C++/Rust.", vim.log.levels.WARN)
      end

      -- Configuration pour C#
      -- Vérification que netcoredbg existe
      if vim.fn.executable("netcoredbg") == 1 then
        dap.adapters.coreclr = {
          type = "executable",
          command = "netcoredbg",
          args = { "--interpreter=vscode" },
        }

        dap.configurations.cs = {
          {
            type = "coreclr",
            name = "launch - netcoredbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
          },
        }
      else
        vim.notify("netcoredbg non trouvé. Veuillez l'installer pour le débogage C#.", vim.log.levels.WARN)
      end

      -- Intégration avec Telescope
      require("telescope").load_extension("dap")
    end,
  },

  -- Ajout de mason-nvim-dap pour installer automatiquement les adaptateurs
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "python",
          "cppdbg",
          "codelldb",
          "js",
          "bash",
        },
        automatic_setup = true,
        automatic_installation = true,
        handlers = {
          function(config)
            -- Tous les adaptateurs qui ne sont pas gérés spécifiquement
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })
    end,
  },
}
