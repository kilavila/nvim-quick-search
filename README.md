# nvim-quick-search

Need to look something up on the old interwebs?

> Current issues: escaping certain special characters like `!`, `$`, `%`, `&` etc..

## Features
- Search for word/line/selection
- Automatically append file extension
- Edit search query from Neovim
- Opens in default browser
- Use your favorite search engine

## Installation
With [lazy.nvim](https://github.com/folke/lazy.nvim)
```
{ "kilavila/nvim-quick-search" }
```

## Usage
```lua
:lua require("nvim-quick-search").search("ENGINE", "MODE", FILETYPE, EDIT)

-- type: string
{
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
  -- don't see your favorite search engine? make a pull request or let me know so I can add it
}

-- type: string
{
    'word', -- gets the word under the cursor
    'line', -- gets the line under the cursor
    'selection' -- gets the current/last selection
}

-- type: boolean
-- will append file extension to the end of the search query
FILETYPE = true

-- type: boolean
-- will open the search query in floating window in Neovim for editing
EDIT = true

-- example: duckduckgo, selected text(visual mode), no extension, no editing
:lua require"nvim-quick-search".search("duckduckgo", "selection", false, false)
```

## Commands
```lua
QuickSearch -- defaults to; Brave search, word mode, append file extension, edit in Neovim before search
QuickSearchHelp
```
