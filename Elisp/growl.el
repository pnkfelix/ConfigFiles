(defun growl-page-me (title msg)
  (cond
    ((executable-find "notify-send")
     (start-process "page-me" nil
                    ;; 8640000 ms = 1 day
                    "notify-send" "-u" "normal" "-i" "gtk-dialog-info"
                    "-t" "8640000" "emacs"
                    msg))
    ((executable-find "growlnotify.com")
     (start-process "page-me" "*debug*" "growlnotify.com" "/a:Emacs" "/n:IRC" msg))
    ((executable-find "growlnotify")
     (start-process "page-me" "*debug*" "growlnotify" "-a" "Emacs" "-m" msg))
    ((executable-find "osascript")
     (apply 'start-process `("page-me" nil
			     "osascript"
			     "-e" "tell application \"GrowlHelperApp\""
			     "-e" "register as application \"Emacs\" all notifications {\"emacs\", \"rcirc\", \"compile\"} default notifications {\"emacs\"}"
			     "-e" ,(concat "notify with name \"emacs\" title \"" title "\" description \""
					   msg "\" application name \"Emacs\"")
			     "-e" "end tell")))

    (t (error "No method available to page you."))))

(provide 'growl)
