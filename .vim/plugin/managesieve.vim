" vim:foldmethod=indent

" VimManagesieve - a vim python extension for using managesieve.
"
" Copyryight (c) 2009-2010 Marc Joliet <marcec@gmx.de>
"
" The functionality is implemented as a Python class wrapping around
" python-managesieve [1].  By default it will load and put the currently active
" script from/to the server.  Alternatively, you can pass a name argument to
" manually select the script, or use the select_script() method to see a list of
" all scripts on the server (if there is more than one script, that is).
"
" [1] http://python-managesieve.origo.ethz.ch/
"
" TODO: wrap everything in vimscript functions for auto-completion goodness
"       (how to keep multiple objects, though? A select function? A string
"       argument and some form of ":exe 'py ' . string . 'func_name()'"?)

if !has('python')
    echo "vimsieve needs python support!"
    finish
end

" TODO: find sane defaults! (or at least a better way to handle this)
if !exists("g:vimsieve_host")   | let g:vimsieve_host = 'mail.huntemann.uni-oldenburg.de' | endif
if !exists("g:vimsieve_port")   | let g:vimsieve_port = 2000       | endif
if !exists("g:vimsieve_usetls") | let g:vimsieve_usetls = 1         | endif
" if !exists("g:vimsieve_host")   | let g:vimsieve_host = 'localhost' | endif
" if !exists("g:vimsieve_port")   | let g:vimsieve_port = 12000       | endif
" if !exists("g:vimsieve_usetls") | let g:vimsieve_usetls = 0         | endif

python << EOF
import vim
try:
    from managesieve import MANAGESIEVE
except ImportError, e:
    print "*** Error: ***"
    print e.message

# TODO: rewrite so that arguments are saved in __init__() and __call__() returns
#       a function
# TODO: the __safety_checks() function seems to be a viable solution, if no
#       issues come up with it, remove this class
class safety_checks(object):
    def __init__(self, func):
        self.func = func
        # self.__func_instance = func.__self__

    def __call__(self):
        def tmp(*args, **kargs):
            print repr(self.func.__self__)
            print "Conducting safety checks..."

            print "*args contains: " + repr(args)
            print "**kargs contains: " + repr(kargs)

            if 'name' in kargs:
                name = kargs['name']
            if 'use' in kargs:
                use = kargs['use']

            try:
                self.func.__self__._check_loggedin()
                self.func.__self__._check_selected(name=name)
            except BaseException, e:
                print "*** Error: ***"
                print e.message
                return
            except:
                print "Unknown error"
                return

            print "calling" + repr(self.func)
            func(self, *args, **kargs)
        return tmp

class vimsieve(object):
    """A class implementing a managesieve client in Vim."""

    def __init__(self, host=None, port=None, use_tls=None):
        """Initialise a vimsieve object.

        Optional arguments:
          host:       The managesieve server hostname or address.
          port:       The managesieve port.
          use_tls:    Use TLS if True (default) and the server supports it or
                  force off.

          By default, none of these are defined.  Instead, the global variables
          g:vimsieve_{host,port,usetls} will be evaluated.  Their defaults are
          "localhost", 12000 and True, respectively.
        """

        self._sieve_host = (host if host else vim.eval('g:vimsieve_host'))
        self._sieve_port = int((port if port else vim.eval('g:vimsieve_port')))
        self._use_tls = (True if use_tls else
                    (True if int(vim.eval('g:vimsieve_usetls')) == 1 else False))
        self.__loggedin = False
        self.__selected = None

    def __del__(self):
        try:
            self.__srv.logout() # make sure we log out cleanly on exit
            del self.__srv # TODO: see if this is necessary at all
        except:
            pass # if we never logged in, self.__srv will not exist

    def __get_selected(self):
        return self.__selected

    def __check_selected(self, name=None):
        """A helper function that checks if a script is currently selected.
           
           If there is no script currently selected, the script that is marked
           as active on the server is selected. If "name" is provided, checking
           is skipped.
        """

        if name:
            pass # if name is specified, do not care about currently selected
        elif not self.__selected:
            print "No script selected!"
            selected = self.__choose_script(use="active")

            if selected:
                self.__selected = selected
            # else:
            #     # if the server doesn't have an active script, let user choose manually
            #     print "No active script selectable! Please choose manually."
            #     self.__selected = self.__choose_script(use=None,
            #                 msg="'Please select a script: '")

    def __check_loggedin(self):
        """A helper function that checks whether the user is currently logged in to
        the managesieve server.

        If the user is not logged in, a login is attempted.
        """

        if not self.__loggedin:
            print "Not logged in!"
            try:
                self.login()
            except:
                raise
            self.__loggedin = True

    def __choose_script(self, name=None, use=None, msg=None):
        """A helper function for choosing which script from the server to use.

           By default it presents a pseudo-menu for selecting a script.
           Otherwise it selects a script by name or whether it is the active or
           currently selected script.  Note that specifying a name overrides the
           other options.
        """

        res, scripts = self.__srv.listscripts()
        if res == 'OK':
            if name: # override other options if script name manually specified
                selected = name
            elif use == None:
                idx = -1 # if there is only one script, this selects it
                # print a table of all scripts along with indices; indicate the
                # active and selected scripts, if any
                for i,(script,is_active) in enumerate(scripts):
                    print i, ": ", script, \
                        (" (active)" if is_active else ""), \
                        (" (selected)" if self.__selected == script else "")
                # let user choose script now
                while ( idx >= len(scripts) or idx < 0 ) and len(scripts) > 1:
                    idx = int(vim.eval("input(" + msg + ")"))
                selected = scripts[idx][0]
            elif use == "active":
                for script,is_active in scripts:
                    if is_active:
                        selected = script
                        break
                else:
                    print "No active script!"
            elif use == "selected":
                selected = self.__selected
            else:
                print "No valid value for \"use\" specified!"
                print "\"use\" can be either 'active' or 'selected'."
                selected = None

            return selected

        else:
            print "Error listing scripts!"
            return None

    def __safety_checks(func):
        """A decorator function that creates new methods for automatically checking
        login status and whether a script was selected."""
        # A prerequisite of the function this decorator is to be applied to is
        # that it has a "name" keyword argument. On the other hand, "use" is optional.
        name = func.__defaults__[0]
        if 'use' in func.__code__.co_varnames:
            use = func.__defaults__[1]
            def tmp(self, name=name, use=use):
                print "Conducting safety checks..."

                # Get the default values of the function arguments. If the argument
                # is passed in # *args or **kargs, use that instead

                try:
                    self.__check_loggedin()
                    self.__check_selected(name=name)
                except BaseException, e:
                    print "*** Error: ***"
                    print e.message
                    return
                except:
                    print "Unknown error"
                    return
                func(self, name=name, use=use)
        else:
            def tmp(self, name=name):
                print "Conducting safety checks..."

                # Get the default values of the function arguments. If the argument
                # is passed in # *args or **kargs, use that instead

                try:
                    self.__check_loggedin()
                    self.__check_selected(name=name)
                except BaseException, e:
                    print "*** Error: ***"
                    print e.message
                    return
                except:
                    print "Unknown error"
                    return

                func(self, name=name)
        tmp.__doc__      = func.__doc__
        tmp.__defaults__ = func.__defaults__
        tmp.__name__     = func.__name__

        return tmp

    @__safety_checks
    def get_script(self, name=None, use="selected"):
        """A function for getting a script from a managesieve server.

        It selects a script by name if specified, otherwise it uses the
        currently selected script.
        """

        try:
            selected = self.__choose_script(name=name, use=use,
                            msg="'Please select a script to get: '")
            if selected:
                res, data = self.__srv.getscript(selected)
                if res == "OK":
                    self.__selected = selected
                    fname = vim.eval("expand('%')") # get current file name

                    # if the current buffer is new, vim.eval(...) returns None
                    is_new_buf = bool(fname)
                    if not is_new_buf:
                        # open a temporary file for editing
                        fname = vim.eval('tempname()')
                        vim.command("edit " + fname)

                    # overwrite current buffer with downloaded script
                    vim.current.buffer[:] = data.split('\n')
                    vim.command('set filetype=sieve')
                    vim.command("write " + fname)
                else:
                    print "Error: ", res
            else:
                print "Script \"" + repr(selected) + "\" not available/selectable!"
        except (BaseException, vim.error), e:
            print "*** Error: ***"
            print e.message
        except:
            # catch misc. exceptions, including string exceptions raised when
            # pressing Ctrl-C in a vim input dialog, and reraise them (for
            # diagnostic purposes)
            raise

    @__safety_checks
    def put_script(self, name=None):
        """A function for saving a script to a managesieve server.

        It selects a script by name if specified, otherwise it uses the
        currently selected script.

        Note that the currently selected script is not changed.  Also note that
        if the current file is not of file type 'sieve', it will not be saved to
        the server.
        """

        if vim.eval('&filetype') == 'sieve':
            data = '\n'.join(vim.current.buffer[:])
            selected = (name if name else self.__selected)

            res = None
            if selected:
                res = self.__srv.putscript(selected, data)

            if res == 'OK':
                print "successfully saved script"
            else:
                print "Error: ", res
        else:
            print "Not a sieve script! Set \"filetype\" to \"sieve\" if you are"
            print "really sure that the current file is a sieve script."

    @__safety_checks
    def del_script(self, name=None, use=None):
        """A function for deleting a script from a managesieve server.

        It selects a script by name if specified, otherwise it uses the "use"
        function parameter.  If neither are given, a pseudo-menu is presented.

        Note that it is possible to delete the currently selected script, a
        replacement must be chosen manually (obviously).
        """

        selected = self.__choose_script(name=name, use=use,
                        msg="'Please select the script to delete: '")

        if selected:
            msg = "'Are you sure you want to delete \"" + selected + "\" (yes/no)?'"
            res = ""
            while res not in ("yes", "no"):
                res = vim.eval("input(" + msg + ")").lower()
                if res == "yes":
                    self.__srv.deletescript(selected)
                    if selected == self.__selected:
                        self.__selected = None
                elif res == "no":
                    print "Script", "\"" + selected + "\"", "not deleted!"
        else:
            print "Script not available/selectable!"

    def select_script(self):
        """A helper function for changing the currently selected script.
        """

        try:
            self.__check_loggedin()
        except BaseException, e:
            print "*** Error: ***"
            print e.message
            return

        # return value will either be None or a script name
        self.__selected = self.__choose_script(use=None, msg="'Please select a script: '")

    @__safety_checks
    def set_active(self, name=None, use=None):
        """A function for setting the active script on a managesieve server.

        It selects a script by name if specified, otherwise it uses the "use"
        function parameter. If neither are given, a pseudo-menu is presented. It
        leaves the currently selected script at its current value.
        """

        selected = self.__choose_script(name=name, use=use,
                        msg="'Please select the new active script: '")
        if selected:
            self.__srv.setactive(selected)

    def login(self):
        """Log in to a managesieve server.
        """

        try:
            username = vim.eval("input('Enter Username: ')")
            passwd = vim.eval("inputsecret('Enter password: ')")
        except:
            raise

        self.__srv = MANAGESIEVE(self._sieve_host, self._sieve_port, self._use_tls)
        res = self.__srv.login('', username, passwd) # automatically chooses best login method
        del passwd

        if res == 'OK':
            print "login successful"
            self.__loggedin = True
        else:
            # TODO: is "ValueError" a good choice?
            raise ValueError("Login error: bad username/password?")

    def logout(self):
        """Log out of a managesieve server."""

        self.__srv.logout()
        self.__loggedin = False

    selected = property(fget=__get_selected,
                doc="The name of the currently selected sieve script. (read-only)")

vim_sieve = vimsieve() # create an instance with the default values
#safety = safety_checks(vim_sieve.get_script)
#vim_sieve.get_script = safety()
EOF
