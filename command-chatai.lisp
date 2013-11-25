(in-package :chatai-tan)

(defun chatai-commands ()
  (format t "~a~%"
	  (let ((output
		 (error-logging-file ((concatenate 'string
						   chatai-directory "error.log")
				      :direction :output
				      :if-exists :append
				      :if-does-not-exist :create)
		   (chatai-command (nth 1 *posix-argv*)
				   (nth 2 *posix-argv*)))))
	    (if (null output)
		""
		output))))

(save-lisp-and-die "chatai-command"
		   :toplevel #'chatai-commands
		   :executable t)
