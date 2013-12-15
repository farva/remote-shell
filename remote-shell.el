;; -*- lexical-binding: t; -*-

(defconst remote-edit-starter-file-name "remote_edit_starter"
  "File name of remote script in local load-path.
At the start of each remote-shell this file is copied to the remote host.")

(defconst remote-shell-edit-tmp-file-dmz-string "-<0=0>-"
  "Prefix and suffix added to the temporary file needed by remote EDITOR.
This will act as a DMZ to distinguish it from other text in the buffer.")

(defconst remote-shell-resources-path (concat (file-name-directory load-file-name)
                                              (convert-standard-filename "resources/"))
  "Path to the resources needed for this package (e.g. remote edit starter file).")

(defun string-natural-int-p (string)
  (if (string-match "\\`[0-9]+\\'" string)
      t
    nil))

(defun remote-shell (host user shell method &optional port)
  "Opens a shell to remote host using TRAMP"
  (interactive "sHost: \nsUser: \nsShell: \nsMethod: \nsPort: ")
  (if (not remote-shell-resources-path)
      (error "Not initialized: remote-shell-resources-path is nil")
    (with-temp-buffer
      (let ((remote-home-dir (format "/%s:%s@%s%s:~/" method user host
				     (if (and port (string-natural-int-p port))
					 (concat "#" port)
				       ""))))
	(cd remote-home-dir)
	(copy-file (expand-file-name
		    (concat remote-shell-resources-path remote-edit-starter-file-name))
		   (concat remote-home-dir "." remote-edit-starter-file-name)
                   t))
      (let ((explicit-shell-file-name (concat "/bin/" shell)))
	(shell (concat "*" host "*"))))))

; TODO: look at comint-preoutput-filter-functions. maybe can be done without user intervention.'
(defun attach-current-remote-editing ()
  "Attach to a remote editing session of the current buffer."
  (interactive)
  (let* ((tmp-file-local-path
	  (save-excursion
	    (goto-char (point-max))
	    (re-search-backward (concat remote-shell-edit-tmp-file-dmz-string "\\(.+\\)"
                                        remote-shell-edit-tmp-file-dmz-string))
	    (match-string 1)))
	 (base-path (if (char-equal ?/ (string-to-char tmp-file-local-path))
			(progn
			  (string-match "\\(^/[^/]+\\)/" default-directory)
			  (match-string-no-properties 1 default-directory))
		      default-directory))
	 (tmp-file-tramp-path (concat base-path tmp-file-local-path)))
    (start-process "remote-edit" nil "emacsclient" tmp-file-tramp-path)
    ; TODO: use sentinal to send releasing input to comint when "emacsclient async process finishes
    (message "Press <RET> when done editing.")))

(provide 'remote-shell)
