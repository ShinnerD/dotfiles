local M = {}

local function package_of(path)
  local dir = vim.fn.fnamemodify(path, ":p:h")
  local pkg = dir:match("/src/[^/]+/java/(.+)$")
  if not pkg then return nil end
  return (pkg:gsub("/", "."))
end

local templates = {
  { label = "Class",                   decl = "public class %s {",     imports = {} },
  { label = "Record",                  decl = "public record %s(",     imports = {}, record = true },
  { label = "Interface",               decl = "public interface %s {", imports = {} },
  { label = "Enum",                    decl = "public enum %s {",      imports = {} },
  { label = "Spring @Service",         decl = "public class %s {",     imports = { "org.springframework.stereotype.Service" },                  annotation = "@Service" },
  { label = "Spring @RestController",  decl = "public class %s {",     imports = { "org.springframework.web.bind.annotation.RestController" }, annotation = "@RestController" },
  { label = "Spring @Configuration",   decl = "public class %s {",     imports = { "org.springframework.context.annotation.Configuration" },   annotation = "@Configuration" },
}

local function apply(buf, tpl)
  local path = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(path, ":t:r")
  local pkg = package_of(path)
  local indent = vim.bo[buf].expandtab and string.rep(" ", vim.bo[buf].shiftwidth) or "\t"

  local lines = {}
  if pkg then
    vim.list_extend(lines, { "package " .. pkg .. ";", "" })
  end
  if #tpl.imports > 0 then
    for _, imp in ipairs(tpl.imports) do
      table.insert(lines, "import " .. imp .. ";")
    end
    table.insert(lines, "")
  end
  if tpl.annotation then
    table.insert(lines, tpl.annotation)
  end

  local decl = tpl.decl:format(name)
  table.insert(lines, decl)
  local cursor
  if tpl.record then
    table.insert(lines, ") {")
    table.insert(lines, "}")
    cursor = { #lines - 2, #decl } -- right after the "("
  else
    table.insert(lines, indent)
    table.insert(lines, "}")
    cursor = { #lines - 1, #indent }
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, cursor)
  vim.cmd("startinsert!")
end

function M.prompt(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.ui.select(templates, {
    prompt = "New Java file",
    format_item = function(t) return t.label end,
  }, function(choice)
    if choice and vim.api.nvim_buf_is_valid(buf) then
      apply(buf, choice)
    end
  end)
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.java",
  callback = function(ev)
    local empty = vim.api.nvim_buf_line_count(ev.buf) == 1
      and vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] == ""
    local path = vim.api.nvim_buf_get_name(ev.buf)
    if empty and vim.fn.getfsize(path) <= 0 then
      vim.schedule(function() M.prompt(ev.buf) end)
    end
  end,
})

return M
