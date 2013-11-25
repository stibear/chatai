(in-package :chatai-tan)

(defmacro with-skype-bus (&body body)
  `(with-open-bus (bus (session-server-addresses))
     (with-introspected-object (skype bus "/com/Skype" "com.Skype.API")
       (flet ((skype (command)
		(skype "com.Skype.API" "Invoke" command)))
	 (skype "NAME chatai-tan")
	 (skype "PROTOCOL 8")
	 ,@body))))

(defmacro style-warning-suppressor (&rest body)
  `(handler-bind ((style-warning #'muffle-warning))
     ,@body))

(defun get-latest-message-id (room-id)
  (parse-integer
   (scan-to-strings
    "\\d*$"
    (with-skype-bus
      (skype (format nil "GET CHAT ~a RECENTCHATMESSAGES" room-id))))))

(defun get-message-body (message-id)
  (regex-replace-all
   "CHATMESSAGE \\d+ BODY "
   (with-skype-bus
     (skype (format nil "GET CHATMESSAGE ~a BODY" message-id)))
   ""))

(defun get-message-fhandle (message-id)
  (regex-replace-all
   "CHATMESSAGE \\d+ FROM_HANDLE "
   (with-skype-bus
     (skype (format nil "GET CHATMESSAGE ~a FROM_HANDLE" message-id)))
   ""))

(defun chat-to-room (room-id text)
  (with-skype-bus
    (skype (format nil "CHATMESSAGE ~a ~a" room-id text))
    (receive-message (bus-connection bus))))

(defun chat-to-npca-room (text)
  (chat-to-room npca-room text))

(defun message-from-npca-room (id)
  (with-skype-bus
    (skype (format nil "GET CHATMESSAGE ~a BODY" id))))

(defmacro forever (&body body)
  `(do ()
       (nil)
     ,@body))

(defun change-random-denominator ()
  (unless (string= my-name
		   (get-message-fhandle
		    (get-latest-message-id stibear-tgyoza-room)))
    (let ((var (multiple-value-bind (tmp num-vector)
		   (scan-to-strings
		    "確率:[ \\t]*1/(\\d+)"
		    (get-message-body
		     (get-latest-message-id stibear-tgyoza-room)))
		 (if num-vector (parse-integer (aref num-vector 0))))))
      (cond (var (setf random-denominator var)
		 (chat-to-room stibear-tgyoza-room
			       (format nil
				       "確率(random-denominator)=~a.~%OK."
				       random-denominator)))
	    (t (chat-to-room stibear-tgyoza-room "ぽよ"))))))

(defun reply-replace (string user)
  (regex-replace-all "[ \\t]*(>|＞)[ \\t]*\\w+$" string
		     (format nil " >~a" user)))


(defun chatai-command (sentence handle &key (mode :release))
  (if (= (length sentence) 0)
      (progn (warn "sentence's length is ~a~&" (length sentence)) "")
      (let ((sent (regex-replace-all "(\\[.*\\]|\\&.*;|\\z)" sentence "")))
	(unless (or (null sent) (equal sent ""))
	  (let* ((chataied-sent (chatai sent :mode mode))
		 (psent (unless (or (null chataied-sent)
				    (equal chataied-sent ""))
			  (regex-replace-all
			   "(\\[.*\\]|\\&.*;|\\z)"
			   (reply-replace chataied-sent handle)
			   ""))))
	    (when (or psent
		      (not (scan "チャタイ" sent))
		      (not (string= handle my-name)))
	      (if (or (scan "[ \\t]*(>|＞)[ \\t]*ちゃたい$" sent)
		      (scan "[ \\t]*(>|＞)[ \\t]*れいん$" sent)
		      (scan "[ \\t]*(>|＞)[ \\t]*玲音$" sent))
		  (format nil "~a >~a" psent handle)
		  psent)))))))

;; 汚
(defun chatai-loop (room)
  (style-warning-suppressor
   (let ((tmp1 (get-latest-message-id room)))
     (forever
       (change-random-denominator)
       (let ((new1 (get-latest-message-id room)))
	 (when (not (= tmp1 new1))
	   (setf tmp1 new1)
	   (let ((sent (regex-replace-all "(\\[.*\\]|\\&.*;|\\z)"
					  (get-message-body new1) "")))
;	     (push-to-db sent (h-list sent))
	     (unless (and (null sent) (equal sent ""))
	       (let* ((handle (get-message-fhandle new1))
		      (chataied-sent (ignore-errors (chatai sent :mode :debug)))
		      (psent
		       (when chataied-sent
			 (regex-replace-all
			  "(\\[.*\\]|\\&.*;|\\z)"
			  (reply-replace chataied-sent handle)
			  ""))))
		 (when (and psent
			    (if (scan "ちゃたい" sent)
				t
				(zerop (random random-denominator
					       (make-random-state t))))
			    (not (scan "チャタイ" sent))
			    (not (string= handle my-name)))
		   (chat-to-room room
				 (if (or (scan "ちゃたい" sent)
					 (scan "tgyoza" sent))
				     (format nil
					     "~A >~A"
					     psent handle)
				     psent))))))))))))
