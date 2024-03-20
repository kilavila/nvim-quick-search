local api = vim.api
local buf, win

local window_open = false
local search_modes = { 'word', 'line', 'selection' }
local search_engines = {
  ['baidu'] = 'https://www.baidu.com/s?wd=',
  ['bing'] = 'https://www.bing.com/search?q=',
  ['brave'] = 'https://search.brave.com/search?q=',
  ['duckduckgo'] = 'https://duckduckgo.com/?q=',
  ['ecosia'] = 'https://www.ecosia.org/search?q=',
  ['kvasir'] = 'https://www.kvasir.no/alle/',
  ['google'] = 'https://www.google.com/search?q=',
  ['qwant'] = 'https://www.qwant.com/?q=',
  ['startpage'] = 'https://startpage.com/do/search?query=',
  ['yandex'] = 'https://yandex.com/search/?text=',
}

local engine_name = ''
local engine_url = ''
local query = ''
local ext = ''

local function open_window()
  if window_open then
    return
  end
  window_open = true

  buf = api.nvim_create_buf(false, true)
  local border_buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'bufferlist')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = 1
  local win_width = math.ceil(width * 0.6)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
  }

  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
  }

  local border_title = ' ' .. engine_name .. ' '
  local border_lines = { '╭' .. border_title .. string.rep('─', win_width - string.len(border_title)) .. '╮' }
  local middle_line = '│' .. string.rep(' ', win_width) .. '│'
  for _ = 1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╰' .. string.rep('─', win_width) .. '╯')
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

  api.nvim_win_set_option(win, 'cursorline', true)
end

local function get_current_word()
  local word = api.nvim_call_function('expand', { '<cword>' })

  return word
end

local function get_current_line()
  local line = api.nvim_get_current_line()
  line = string.gsub(line, '^%s*(.-)%s*$', '%1')

  return line
end

local function get_current_selection()
  api.nvim_command('normal! gv"-y<cr>')
  local reg = vim.fn.getreg('-')

  return reg
end

local function help()
  local help_text = 'Usage: lua require(\'nvim-quick-search\').search(ENGINE, MODE, FILETYPE, EDIT)'

  help_text = help_text .. '\n\nSearch engines:\n------------\n'
  for engine, _ in pairs(search_engines) do
    help_text = help_text .. engine .. '\n'
  end

  help_text = help_text .. '\n\nModes:\n------------\n'
  for _, mode in pairs(search_modes) do
    help_text = help_text .. mode .. '\n'
  end

  help_text = help_text .. '\n\nFiletype: If true, the filetype will be appended to the query'
  help_text = help_text .. '\n\nEdit: If true, you can edit the query before it is opened in your default browser'

  print(help_text)
end

local function close_window()
  if not window_open then
    return
  end
  window_open = false

  api.nvim_win_close(win, true)
end

local function run_search()
  if window_open then
    close_window()
  end

  query = string.gsub(query, '"', '\\"')
  query = string.gsub(query, '!', '\\!')

  local url = '"' .. engine_url .. query .. ext .. '"'
  url = string.gsub(url, ' ', '+')

  api.nvim_command('!open ' .. url)
end

local function get_engine(user_input)
  for name, url in pairs(search_engines) do
    if string.find(user_input, name) then
      return name, url
    end
  end
end

local function get_mode(mode)
  local search_query = ''

  if mode == 'word' then
    search_query = get_current_word()
  elseif mode == 'line' then
    search_query = get_current_line()
  elseif mode == 'selection' then
    search_query = get_current_selection()
  end

  return search_query
end

local function get_filetype(filetype)
  if filetype == true then
    local extension = api.nvim_buf_get_option(0, 'filetype')
    return ' ' .. extension
  else
    return ''
  end
end

local function update_query()
  query = get_current_line()
  run_search()
end

local function update_window()
  api.nvim_buf_set_option(buf, 'modifiable', true)

  if query then
    api.nvim_buf_set_lines(buf, 0, -1, false, { query })
  else
    api.nvim_buf_set_lines(buf, 0, -1, false, { '' })
  end
end

local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function set_mappings()
  local normal_mappings = {
    ['<esc>'] = 'close_window()',
    ['<cr>']  = 'update_query()',
  }

  for k, v in pairs(normal_mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"nvim-quick-search".' .. v .. '<cr>', {
      nowait = true, noremap = true, silent = true
    })
  end
end

local function quick_search()
  open_window()
  update_window()
  set_mappings()
  api.nvim_win_set_cursor(win, { 1, 0 })
end

local function search(engine, mode, filetype, edit)
  if not engine
      or not mode
      or not filetype
      or not edit then
    print('Invalid arguments!\n\nCheck the README on GitHub: https://github.com/kilavila/nvim-quick-search')
  end

  engine_name, engine_url = get_engine(engine)
  query = get_mode(mode)
  ext = get_filetype(filetype)

  if edit == true then
    quick_search()
  else
    run_search()
  end
end

return {
  search = search,
  help = help,
  get_current_word = get_current_word,
  get_current_line = get_current_line,
  get_current_selection = get_current_selection,
  get_engine = get_engine,
  get_mode = get_mode,
  get_filetype = get_filetype,
  open_window = open_window,
  close_window = close_window,
  update_query = update_query,
  update_window = update_window,
  move_cursor = move_cursor,
  set_mappings = set_mappings,
  quick_search = quick_search
}
