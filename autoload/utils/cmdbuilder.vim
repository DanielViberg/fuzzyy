vim9script

var file_exclude_default = ['*.swp', 'tags']
var dir_exclude_default = ['.git', '.hg', '.svn']

# Deprecated or removed options
if exists('g:files_only_git_files') && g:files_only_git_files
    echo 'fuzzyy: g:files_only_git_files is no longer supported, use :FuzzyGitFiles command instead'
endif
if exists('g:files_respect_gitignore')
    echo 'fuzzyy: g:files_respect_gitignore is deprecated, gitignore is now respected by default'
    g:fuzzyy_files_respect_gitignore = g:files_respect_gitignore
endif
if exists('g:fuzzyy_files_ignore_file')
    echo 'fuzzyy: g:fuzzyy_files_ignore_file is deprecated, use g:fuzzyy_files_exclude_file instead'
    g:fuzzyy_files_exclude_file = g:fuzzyy_files_ignore_file
endif
if exists('g:fuzzyy_files_ignore_dir')
    echo 'fuzzyy: g:fuzzyy_files_ignore_dir is deprecated, use g:fuzzyy_files_exclude_dir instead'
    g:fuzzyy_files_exclude_dir = g:fuzzyy_files_ignore_dir
endif

# Options
var respect_gitignore = exists('g:fuzzyy_files_respect_gitignore') ?
    g:fuzzyy_files_respect_gitignore : 1
var file_exclude = exists('g:fuzzyy_files_exclude_file')
    && type(g:fuzzyy_files_exclude_file) == v:t_list ?
    g:fuzzyy_files_exclude_file : file_exclude_default
var dir_exclude = exists('g:fuzzyy_files_exclude_dir')
    && type(g:fuzzyy_files_exclude_dir) == v:t_list ?
    g:fuzzyy_files_exclude_dir : dir_exclude_default
var include_hidden = exists('g:fuzzyy_files_include_hidden') ?
    g:fuzzyy_files_include_hidden : 1
var follow_symlinks = exists('g:fuzzyy_files_follow_symlinks') ?
    g:fuzzyy_files_follow_symlinks : 0

def Build_rg(): string
    var result = 'rg --files'
    if include_hidden
        result ..= ' --hidden'
    endif
    if follow_symlinks
        result ..= ' --follow'
    endif
    if respect_gitignore
        result ..= ' --no-require-git'
    else
        result ..= ' --no-ignore'
    endif
    var dir_list_parsed = reduce(dir_exclude,
        (acc, dir) => acc .. "-g !" .. dir .. " ", "")

    var file_list_parsed = reduce(file_exclude,
        (acc, file) => acc .. "-g !" .. file .. " ", "")

    return result .. ' ' .. dir_list_parsed .. file_list_parsed
enddef

def Build_fd(): string
    var result = 'fd --type f'
    if include_hidden
        result ..= ' --hidden'
    endif
    if follow_symlinks
        result ..= ' --follow'
    endif
    if respect_gitignore
        result ..= ' --no-require-git'
    else
        result ..= ' --no-ignore'
    endif
    var dir_list_parsed = reduce(dir_exclude,
        (acc, dir) => acc .. "-E " .. dir .. " ", "")

    var file_list_parsed = reduce(file_exclude,
        (acc, file) => acc .. "-E " .. file .. " ", "")

    return result .. ' ' .. dir_list_parsed .. file_list_parsed
enddef

def Build_find(): string
    var opts = ''
    if follow_symlinks
        opts ..= '-L'
    endif
    var result = "find " .. opts .. " . -type f -print"

    var ParseDir = (dir): string => "*/" .. dir .. "/*"
    var dir_list_parsed = reduce(dir_exclude,
        (acc, dir) => acc .. "-not -path " .. ParseDir(dir) .. " ", " ")

    var file_list_parsed = reduce(file_exclude,
        (acc, file) => acc .. "-not -name " .. file .. " ", "")

    return result .. ' ' .. dir_list_parsed .. file_list_parsed
enddef

# GCI doc isn't clear. Get-ChildItem -Recurse -Exclude only matches exclusion
# on the leaf, not the parent path.
#
# Link:
# https://stackoverflow.com/questions/15294836/how-can-i-exclude-multiple-folders-using-get-childitem-exclude#:~:text=The%20documentation%20isn%27t%20clear%20on%20this%2C%20but%20Get%2DChildItem%20%2DRecurse%20%2DExclude%20only%20matches%20exclusion%20on%20the%20leaf%20(Split%2DPath%20%24_.FullName%20%2DLeaf)%2C%20not%20the%20parent%20path%20(Split%2DPath%20%24_.FullName%20%2DParent).
#
# That's why module builds GCI cmd and piping it into Where-filter
def Build_gci(): string
    var build_dir_filter = reduce(dir_exclude, (acc, dir) => acc .. "$_ -notlike '*\\"
        .. dir ..  "\\*' -and $_ -notlike '" .. dir .. "\\*'"
        .. " -and ", "")
            -> trim(" -and ", 2)

    var build_file_filter = reduce(file_exclude, (acc, file) => acc
        .. "$_ -notlike '" .. file .. "' -and ", "")
            -> trim(" -and ", 2)

    var build_filter = "| Where-Object { "
    if len(dir_exclude) > 0
        build_filter ..= build_dir_filter
    endif
    if len(dir_exclude) > 0 && len(file_exclude) > 0
        build_filter ..= " -and "
    endif
    if len(file_exclude) > 0
        build_filter ..= build_file_filter
    endif
    build_filter ..= "} "

    var cmd = "Get-ChildItem . -Name -Force -File -Recurse"
    if include_hidden
        cmd ..= ' -Hidden'
    endif
    if follow_symlinks
        cmd ..= ' -FollowSymlink'
    endif
    if len(dir_exclude) > 0 || len(file_exclude) > 0
        cmd ..= build_filter
    endif

    return "powershell -command " .. '"' .. cmd .. '"'
enddef

def InsideGitRepo(): bool
    return stridx(system('git rev-parse --is-inside-work-tree'), 'true') == 0
enddef

export def Build(): string
    var cmdstr = ''
    if executable('rg') # rg is cross-plaform
        cmdstr = Build_rg()
    elseif executable('fd') # fd is also cross-platform
        cmdstr = Build_fd()
    elseif executable('fdfind') # debian installs fd as fdfind
        cmdstr = Build_fd()
        cmdstr = substitute(cmdstr, '^fd ', 'fdfind ', '')
    elseif respect_gitignore && executable('git') && InsideGitRepo()
        cmdstr = 'git ls-files --cached --other --exclude-standard .'
    elseif has('win32')
        cmdstr = Build_gci()
    else
        cmdstr = Build_find()
    endif
    return cmdstr
enddef
