local vault = vim.fn.expand("~/Documents/obsidian")
-- Discover visible root folders at each invocation; Templates is infrastructure.
local function silo_folders()
  local silos = {}
  for _, name in ipairs(vim.fn.readdir(vault)) do
    if name:sub(1, 1) ~= "." and name ~= "Templates"
      and vim.fn.isdirectory(vault .. "/" .. name) == 1
    then
      table.insert(silos, name)
    end
  end
  table.sort(silos)
  return silos
end

-- Keep the name prompt in a floating window, like the silo picker.
local function work_name_input(callback)
  -- Let Telescope finish closing its picker before opening another window.
  vim.schedule(function()
    local width = math.max(1, math.min(60, vim.o.columns - 4))
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.bo[buffer].bufhidden = "wipe"
    local window = vim.api.nvim_open_win(buffer, true, {
      relative = "editor",
      width = width,
      height = 1,
      row = math.max(0, math.floor((vim.o.lines - 3) / 2)),
      col = math.max(0, math.floor((vim.o.columns - width) / 2)),
      style = "minimal",
      border = "rounded",
      title = " Work folder name ",
      title_pos = "center",
    })
    local finished = false
    local function finish(value)
      if finished then return end
      finished = true
      vim.cmd("stopinsert")
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
      vim.schedule(function() callback(value) end)
    end
    vim.keymap.set({ "n", "i" }, "<CR>", function()
      finish(vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1] or "")
    end, { buffer = buffer, silent = true })
    vim.keymap.set({ "n", "i" }, "<Esc>", function() finish(nil) end,
      { buffer = buffer, silent = true })
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(window),
      once = true,
      callback = function() finish(nil) end,
    })
    vim.cmd("startinsert!")
  end)
end

-- Reuse your existing entry template so its sections stay aligned.
local function log_entry()
  local lines = vim.fn.readfile(vault .. "/Templates/Work log entry.md")
  local today = os.date("%Y-%m-%d")

  for i, line in ipairs(lines) do
    lines[i] = line:gsub("{{date:YYYY%-MM%-DD}}", today)
  end
  return lines
end

vim.api.nvim_create_user_command("WorkLogEntry", function()
  local lines = log_entry()
  table.insert(lines, 1, "")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end, {})

vim.api.nvim_create_user_command("NewWork", function()
  local ok, silos = pcall(silo_folders)
  if not ok or #silos == 0 then
    vim.notify("No silo folders found or vault cannot be read", vim.log.levels.ERROR)
    return
  end
  vim.ui.select(silos, { prompt = "Choose a silo:" }, function(silo)
    if not silo then return end

    work_name_input(function(input)
      if not input then return end
      local name = vim.trim(input)

      if name == "" or name == "." or name == ".."
        or name:find('[\\/:*?"<>|%c]') or name:find("[. ]$")
      then
        vim.notify("Invalid work folder name", vim.log.levels.ERROR)
        return
      end

      if vim.fn.isdirectory(vault .. "/" .. silo) ~= 1 then
        vim.notify("Silo folder no longer exists", vim.log.levels.ERROR)
        return
      end
      local folder = vault .. "/" .. silo .. "/" .. name
      if vim.fn.getftype(folder) ~= "" then
        vim.notify("Work folder already exists", vim.log.levels.ERROR)
        return
      end

      local notes = {
        ["slack chats.md"] = {
          "# Slack chats", "",
          "## Work channel", "",
          "## Original request / conversation", "",
        },
        ["tab group.md"] = {
          "# Tab group", "",
          "## Tickets", "",
          "## Documentation / workplans", "",
          "## PRs / releases / dashboards", "",
        },
        ["work log.md"] = log_entry(),
        ["to-do.md"] = { "# To-Do", "", "- [ ] ", "" },
      }

      local ok, err = pcall(function()
        if vim.fn.mkdir(folder, "p") ~= 1 then
          error("Could not create work folder")
        end
        for filename, lines in pairs(notes) do
          if vim.fn.writefile(lines, folder .. "/" .. filename) ~= 0 then
            error("Could not write " .. filename)
          end
        end
      end)

      if not ok then
        vim.notify(
          tostring(err) .. "\nCheck for a partially created folder: " .. folder,
          vim.log.levels.ERROR
        )
        return
      end

      vim.cmd("edit " .. vim.fn.fnameescape(folder .. "/to-do.md"))
    end)
  end)
end, {})
