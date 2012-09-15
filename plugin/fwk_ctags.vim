"fwk_ctags Plugin, Manage your ctags configurations simple and efficent under Vim
"Copyright (C) 2011-2012  Sergey Vakulenko
"ppdliveNOT-SPAM_atgmail.com
"
"This program is free software: you can redistribute it and/or modify
"it under the terms of the GNU General Public License as published by
"the Free Software Foundation, either version 3 of the License, or
"(at your option) any later version.

"This program is distributed in the hope that it will be useful,
"but WITHOUT ANY WARRANTY; without even the implied warranty of
"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"GNU General Public License for more details.

"You should have received a copy of the GNU General Public License
"along with this program.  If not, see <http://www.gnu.org/licenses/>.

"
"
"last modification: 10.Sept.2012
"(c) Sergey Vakulenko 
"version: 0.6


if exists('g:fwk_ctags_config_to_load') "if no config was set - stop the plugin execution ...
    
"default path to menu, you can change it
if !exists('g:fwk_ctags_popup_menu_root_path')
    let g:fwk_ctags_popup_menu_root_path = 'PopUp.&Tags'
endif

"default ctags options, you can change it
if !exists('g:fwk_ctags_default_flags')
    let g:fwk_ctags_default_flags = '-R --c++-kinds=+p --ocaml-kinds --fields=+iaS --extra=+q'
endif 

"default map to browse config file, you can change it
if !exists('g:fwk_ctags_map_browse_config')
    let g:fwk_ctags_map_browse_config = '\tgcb' 
endif 

"default map to open current config file, you can change it
if !exists('g:fwk_ctags_map_open_curr_config')
    let g:fwk_ctags_map_open_curr_config = '\tgco'
endif 

"default map to refresh config file, you can change it
if !exists('g:fwk_ctags_map_refresh_config')
    let g:fwk_ctags_map_refresh_config = '\tgcr'
endif 


"default tags for 'set tags' option of vim, you can change it
if !exists('g:fwk_ctags_default_tags')
    let g:fwk_ctags_default_tags = ''
endif 



"default ctags options, you can change it
if !exists('g:fwk_ctags_gen_sup_map')
    let g:fwk_ctags_gen_sup_map = '1'
endif 

if !exists('g:fwk_ctags_set_sup_map')
    let g:fwk_ctags_set_sup_map = '2'
endif 

"--------------------------------------------------------------------
"Description: make map for gen/set tags
func s:FWK_genTagsMap(mydict)

    
    let arg_set   = ''
    let arg_gen   = ''
    
    
    if !empty(a:mydict['l_gen'])
        let arg_gen    = "'" . join(a:mydict['l_gen'], "','") . "'"
        let arg_set    = arg_gen
    endif
    
    if !empty(a:mydict['l_set'])
        if !empty(arg_set)
            let arg_set .= ','
        endif
        let arg_set   .= "'" . join(a:mydict['l_set'], "','") . "'"
    endif

    
    let arg_descr = a:mydict['desc']
    
    let arg_map = 'no map'
    if has_key(a:mydict,'map') != 0 | let arg_map = a:mydict['map'] | endif
    
    let arg_user_preferences = "'" . "'"
    
    if !empty(a:mydict['l_pref'])
        let arg_user_preferences  = '"' . "'" . join(a:mydict['l_pref'], "' '") . "'" . '"'
    endif

    let popup_path  = 'PopUp.&Tags.'
    
    let fun_call_gen_tags       = ':call FWK_genTagsByPath(' . arg_user_preferences . ',' .  arg_gen . ')<CR>'
    let fun_call_set_tags       = ':call FWK_setTags('       . arg_set              .                  ')<CR>'
    "echo 'arg_set:' . arg_set
    let fun_call_stub           = ':call FWK_genStub()<CR>'
    
    
    if !empty(arg_map)
        let eval_gen_map  = 'nmap ' . arg_map . g:fwk_ctags_gen_sup_map . ' ' 
        let eval_set_map  = 'nmap ' . arg_map . g:fwk_ctags_set_sup_map . ' '

        if arg_gen != ''  | let eval_gen_map .= fun_call_gen_tags  | else | let eval_gen_map .= fun_call_stub | endif
        if arg_set != ''  | let eval_set_map .= fun_call_set_tags  | else | let eval_set_map .= fun_call_stub | endif
    endif
    
    "for popup_menu
    if arg_descr != ''
        let hotkey_tip_gen = substitute ('( ' . arg_map . g:fwk_ctags_gen_sup_map . ' )' , '\\' , '\\\\' , 'g')
        let hotkey_tip_gen = substitute (hotkey_tip_gen , '\ ', '\\ ', 'g') 
        "echo hotkey_tip_gen
        
        let hotkey_tip_set = substitute('( ' . arg_map . g:fwk_ctags_set_sup_map . ' )' , '\\' , '\\\\' , 'g')
        let hotkey_tip_set = substitute (hotkey_tip_set , '\ ', '\\ ', 'g') 
        
        let arg_descr_gen = substitute (arg_descr , '\ ', '\\ ', 'g') . '.'
        let arg_descr_set = substitute (arg_descr , '\ ', '\\ ', 'g') . '.'
        "echo arg_descr
        
        if arg_gen != ''
            let menu_path = popup_path . arg_descr_gen . '&Generate' . hotkey_tip_gen
            let eval_str_popup_gen = 'amenu ' . menu_path . ' ' . fun_call_gen_tags . fun_call_set_tags
            exe eval_str_popup_gen
            let g:fwk_ctags_private_maps_storage['gmenu'] = add(g:fwk_ctags_private_maps_storage['gmenu'], menu_path )
        endif
        
        if arg_set != ''
            "echo "#3.0 arg_descr::'" . arg_descr_set . "'"
            let menu_path = popup_path . arg_descr_set . '&Set' . hotkey_tip_set
            let eval_str_popup_set = 'amenu ' . menu_path . ' ' . fun_call_set_tags
            "echo "#3 eval_str_popup_set:" . eval_str_popup_set
            exe eval_str_popup_set
            
            let g:fwk_ctags_private_maps_storage['smenu'] = add(g:fwk_ctags_private_maps_storage['smenu'], menu_path )
        endif
        
    endif

    if !empty(arg_map)
        exe eval_set_map
        exe eval_gen_map
        
        let g:fwk_ctags_private_maps_storage['smap'] = add(g:fwk_ctags_private_maps_storage['smap'], arg_map . g:fwk_ctags_set_sup_map)
        let g:fwk_ctags_private_maps_storage['gmap'] = add(g:fwk_ctags_private_maps_storage['gmap'], arg_map . g:fwk_ctags_gen_sup_map)
    endif
 
endfunc

"--------------------------------------------------------------------
"Description: this function generate tags for all paths. Tag file will be
"created by path taked from last variable of massive
"--------------------------------------------------------------------
func FWK_setTags(...)

    let &tags = g:fwk_ctags_default_tags
    for s in a:000
        "if match(&tags,substitute(s,'\\','\\\\','g')) == -1
        if len(a:000) > 1
            let &tags .= ','
        endif
            "let &tags .= s . g:PLFM_SL . 'tags'
            let &tags .= substitute(s,'\ ','\\ ','g')  . '/' . 'tags'

        "endif
    endfor

endfunc

"--------------------------------------------------------------------
"Description: stub for maps
"--------------------------------------------------------------------
fun FWK_genStub()
    echo 'there is nothing to do for this map'
endfunc

"--------------------------------------------------------------------
"Description: this function generate tags for all paths. Tag file will be
"created by path taked from last variable of array
"--------------------------------------------------------------------
func FWK_genTagsByPath(ctags_advanced_options,...)

    if a:0 == 0
        return
    endif

    for s in a:000
        
        let ctags_flags = g:fwk_ctags_default_flags . ' ' . a:ctags_advanced_options
        
        let ctag_file   =  '"' . s . '/' . 'tags' .  '"'
        let ctag_path   =  '"' . s . '"'
        
        let exe_str     = 'ctags'. ' ' . ctags_flags . ' ' . '-f' . ' ' . ctag_file . ' ' . ctag_path
        
        "Decho ( exe_str )
        echo exe_str
        echo system(exe_str)
    endfor

endfunc


"Depricated
"func FWK_ctags_parse_config_check_end(p, line)
    "let pat_prj_end_ocas = '/\([\ \n]*[}]+\)\?'
    "let end_pattern = a:p 
    "let is_end = substitute(a:line, end_pattern,'\2','')
    "if !empty(is_end)
        "echo 'this is end line: is_end:' . is_end
        "echo 'this is end line: first:' . substitute(a:line, end_pattern,'\1','')
    "endif
"endfunc
"--------------------------------------------------------------------
"Description: parse configuration file and return dictioner of configuration
"--------------------------------------------------------------------
func FWK_ctags_parse_config(file)
    "let file = 'some_file.txt'
    let M = 'FWK_ctags_parse_config'
    
    let pat_symbol   = '\([0-9a-zA-Z\\\/\ _-]\+\)'
    let pat_prj_map  = '^\s*map:'  . pat_symbol . '$'
    let pat_prj_gen  = '^\s*gen:'  . pat_symbol
    let pat_prj_set  = '^\s*set:'  . pat_symbol
    let pat_prj_pref = '^\s*pref:' . '\([0-9a-zA-Z@;,{}()$^:\.=?\[\]*+\\\/\ _-]\+\)' . '$'

    "'\([0-9a-zA-Z?\[\]*+\\\/\ _-]\+\)'
    if !filereadable(a:file) "check if persistency file exist
        echo M . ' file:' . a:file . ' is not reachable. please check it path again'
        return
    endif
    
    let file_content  = readfile(a:file)
    if empty(file_content)
        echo M . 'configuration file:' . a:file . ' is empty, skip action ...'
        return
    endif
    
    let l_prjs = []
    
    let l_gen  = []
    let l_set  = []
    let l_pref = []
    
 
    """ADVANCED PARSE.
    let pat_parse_full_prj = '[\ \n]*\([a-zA-Z0-9\ ]\+\)[\ \n]*{\([0-9a-zA-Z@;,{}()$^:\.=?\[\]*+\\\/\ _-\n]\{-}\)}\(.*\)'
    let new_content = join(file_content,"\n")

    while !empty(substitute(new_content, "[\n\ ]",'',"g")) "after substitute, we collect \n. Need to remove them before check 

        let prj_description = substitute(new_content, pat_parse_full_prj,'\1','')   "this is <description> { ... }
        let prj_vars        = substitute(new_content, pat_parse_full_prj,'\2','')   "this is { <content> }
        let new_content     = substitute(new_content, pat_parse_full_prj,'\3','')  
 
        let dict_el         = {}
        let dict_el['desc'] = prj_description
        let l_gen           = []
        let l_set           = []
        let l_pref          = []

        for line in split(prj_vars, "\n")

            if line =~ pat_prj_map
                let dict_el['map'] = substitute(line,pat_prj_map,'\1','')

            elseif line =~ pat_prj_gen
                call add(l_gen,substitute(line,pat_prj_gen,'\1',''))
                "echo 'gen:' . line

            elseif line =~ pat_prj_set
                call add(l_set,substitute(line,pat_prj_set,'\1',''))
                "echo 'set' . line

            elseif line =~ pat_prj_pref
                call add(l_pref,substitute(line,pat_prj_pref,'\1',''))
            endif

        endfor
 
        let dict_el['l_gen']  = l_gen
        let dict_el['l_set']  = l_set
        let dict_el['l_pref'] = l_pref

        call add(l_prjs,dict_el)

    endwhile
    
    
    """SIMPLE PARSE.
    "let pat_prj_bgn  = '^\s*'. pat_symbol . '\n*' .'{'
    "let pat_prj_end  = '^\s*}\s*$'

    "for line in file_content

        "if line =~ pat_prj_bgn
            "let dict_el['desc'] = substitute(line,pat_prj_bgn,'\1','')
            "let l_gen   = []
            "let l_set   = []
            "let l_pref  = []
            ""echo 'bgn:' . line
           
        "elseif line =~ pat_prj_map
            "let dict_el['map'] = substitute(line,pat_prj_map,'\1','')
            
        "elseif line =~ pat_prj_gen
            "call add(l_gen,substitute(line,pat_prj_gen,'\1',''))
            ""call s:FWK_ctags_parse_config_check_end(pat_prj_gen, line)
            ""echo 'gen:' . line
            
        "elseif line =~ pat_prj_set
            "call add(l_set,substitute(line,pat_prj_set,'\1',''))
            ""echo 'set' . line
            
        "elseif line =~ pat_prj_pref
            "call add(l_pref,substitute(line,pat_prj_pref,'\1',''))

        "elseif line =~ pat_prj_end
            ""call s:FWK_ctags_parse_config_check_end(pat_prj_end, line)
            "let dict_el['l_gen']  = l_gen
            "let dict_el['l_set']  = l_set
            "let dict_el['l_pref'] = l_pref
            
            "call add(l_prjs,dict_el)
            "let dict_el = {}
            ""echo 'end:' . line

        "endif
        
        ""echo line
    "endfor

    
    "echo 'projects:' . join(l_prjs,'|')
    return l_prjs

endfunc

func s:FWK_ctags_reset_old_maps_storage()
    let g:fwk_ctags_private_maps_storage                 = {}
    let g:fwk_ctags_private_maps_storage['smap']         = []
    let g:fwk_ctags_private_maps_storage['gmap']         = []
    let g:fwk_ctags_private_maps_storage['smenu']        = []
    let g:fwk_ctags_private_maps_storage['gmenu']        = []
    let g:fwk_ctags_private_maps_storage['default_menus']= []
endfunc    

func s:FWK_ctags_remove_old_maps()
    "unmap all previous maps, if we call refresh (to not have 'dead' maps
    "after refresh)
    "echo 's:FWK_ctags_remove_old_maps: smenu:' . join(g:fwk_ctags_private_maps_storage['smenu'], ';')  
    "echo 's:FWK_ctags_remove_old_maps: openfile:' . join(g:fwk_ctags_private_maps_storage['openfile'], ';')  
    
    "lets check map. For exemple, user can set same map for diff projects,
    "hence map will be unmap twice (this is error!)
        for i in g:fwk_ctags_private_maps_storage['smap']    | if !empty(maparg(i))  | exe 'nunmap '  .  i  | endif | endfor 
        for i in g:fwk_ctags_private_maps_storage['gmap']    | if !empty(maparg(i))  | exe 'nunmap '  .  i  | endif | endfor 

        for i in g:fwk_ctags_private_maps_storage['smenu']          | exe 'aunmenu ' .  i | endfor 
        for i in g:fwk_ctags_private_maps_storage['gmenu']          | exe 'aunmenu ' .  i | endfor 
        for i in g:fwk_ctags_private_maps_storage['default_menus']  | exe 'aunmenu ' .  i | endfor 

        call s:FWK_ctags_reset_old_maps_storage()
endfunc    

"--------------------------------------------------------------------
"Description: main function for fwk_ctags: use it to run parse processing and
"finally to get maps as hotkeys and item in popup menu
"--------------------------------------------------------------------
func s:FWK_ctags_applicate_cfg(file)
    let M = 's:FWK_ctags_applicate_cfg: '
    

    if !filereadable(a:file) "check if persistency file exist
        echo M . ' file:' . a:file . ' is not reachable. please check it path again'
        return
    endif

    call s:FWK_ctags_remove_old_maps()


    let tip_browse                          = substitute('(' . g:fwk_ctags_map_browse_config    .')' , '\\' , '\\\\' , 'g')
    let tip_open                            = substitute('(' . g:fwk_ctags_map_open_curr_config .')' , '\\' , '\\\\' , 'g')
    let tip_refresh                         = substitute('(' . g:fwk_ctags_map_refresh_config   .')' , '\\' , '\\\\' , 'g')
    
    let popup_browse_config                  = g:fwk_ctags_popup_menu_root_path . '.Browse\ Config\ '        . tip_browse
    let popup_open_config_menu_item         = g:fwk_ctags_popup_menu_root_path . '.Open\ Current\ Config\ ' . tip_refresh
    let popup_refresh_config_menu_item      = g:fwk_ctags_popup_menu_root_path . '.Refresh\ Config\ '       . tip_open
    
    let browse_cfg_cmd                      = ':TagsBrowseConfig <CR>'
    let open_cfg_cmd                        = ':e ' . a:file . '<CR>'
    let refresh_cfg_cmd                     = ':TagsLoadConfig ' . a:file  . '<CR>'

    let g:fwk_ctags_private_maps_storage['default_menus']   = [ popup_browse_config, popup_open_config_menu_item, popup_refresh_config_menu_item ]
    
    "set popup menu and maps for refresh/open config file
    exe 'amenu ' .  popup_browse_config             . ' '   . browse_cfg_cmd
    exe 'amenu ' .  popup_open_config_menu_item     . ' '   . open_cfg_cmd
    exe 'amenu ' .  popup_refresh_config_menu_item  . ' '   . refresh_cfg_cmd
    
    exe 'nmap '  . g:fwk_ctags_map_browse_config     . ' '  . browse_cfg_cmd
    exe 'nmap '  . g:fwk_ctags_map_open_curr_config  . ' '  . open_cfg_cmd
    exe 'nmap '  . g:fwk_ctags_map_refresh_config    . ' '  . refresh_cfg_cmd
    
    
    
    "call FWK_ctags_parse_config(a:file)
    for mydict in FWK_ctags_parse_config(a:file)
        call s:FWK_genTagsMap(mydict)
    endfor
    

endfunc

"--------------------------------------------------------------------
"Description: function to browse cfg file with dialog. 
"Use of default vim browse() 
""--------------------------------------------------------------------
func s:FWK_ctags_brose_cfg()
    let cfg_file_path = browse(0, 'Enter path to *.cfg file: ', '', '')
    if !empty(cfg_file_path)
        let cfg_file_path = fnamemodify(cfg_file_path, ':p')
        echo 'cfg_file_path:' . cfg_file_path
        call s:FWK_ctags_applicate_cfg(cfg_file_path)
    endif
endfunc    

"run plugin processing of cfg ...
if !empty(g:fwk_ctags_config_to_load) " if var is exist but empty - user will call plugin later. just stop execution 
    
    "variable for save maps and menu, to have possibilite unset them
    call s:FWK_ctags_reset_old_maps_storage()
    
	call s:FWK_ctags_applicate_cfg(g:fwk_ctags_config_to_load)

endif

command -nargs=1 -bang -complete=file TagsLoadConfig   :call s:FWK_ctags_applicate_cfg('<args>')
command                               TagsBrowseConfig :call s:FWK_ctags_brose_cfg()

endif
