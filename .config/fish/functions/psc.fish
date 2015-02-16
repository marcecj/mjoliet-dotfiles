function psc --description 'Run ps and shows the cgroups hierarchy'

    ps xawf -eo pid,user,cgroup,args

end
