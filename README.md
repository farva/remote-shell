remote-shell
============

This package provides easy establishing of remote-shell (in shell-mode).
The main feature is the support of remote edit (e.g. git commit, crontab -e, ...).
The aim is to do it simply, with no security risks and without even needing emacs on remote host.
This is first draft. Still need to improve to eliminate any user intervention in establishing remote edit.

* Configuration
---------------
  Add this to your .emacs_bash/init_bash.sh (if don't exist create one of them):
```bash
if [ "${INSIDE_EMACS/*tramp*/tramp}" == "tramp" ]
then
      EDITOR_PATH=$HOME/.remote_edit_starter
      chmod +x $EDITOR_PATH
      export EDITOR=$EDITOR_PATH
      export VISUAL=$EDITOR_PATH
fi
```

  And in your .emacs_tcsh/init_tcsh.sh:
```csh
if ( "$INSIDE_EMACS" !~ "*tramp*" ) then
      EDITOR_PATH=$HOME/.remote_edit_starter
      chmod +x $EDITOR_PATH
      setenv EDITOR $EDITOR_PATH
      setenv VISUAL $EDITOR_PATH
endif
```

* Initialization
----------------
  Add this to your init file:
```lisp
(require 'remote-shell)
```

* Usage
-------
  `M- remote-shell' - connect to remote shell.
  
  `M- attach-current-remote-editing' - when remote editing started, execute this to attach to it.
  Indication on the screen will be apparent.

