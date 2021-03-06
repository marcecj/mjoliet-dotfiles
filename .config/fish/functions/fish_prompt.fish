# define my own fish prompt
function fish_prompt

    # save the status of the command run from the last prompt
    set last_status $status

    # define some colors
    set lightblue (set_color --bold A0A0FF)
    set defcolor (set_color --bold A0A0A0)

    # first line
    printf "$defcolor>> ($lightblue%s@%s$defcolor)" (whoami) (hostname|cut -d. -f1)
    printf "-($lightblue%s$defcolor)" (date "+%R:%S")
    printf "-($lightblue%s$defcolor)\n" (prompt_pwd)
    # second line
    printf ">> ($last_status) %% "

end
