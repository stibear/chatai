(in-package :chatai-tan)

(defun copy-to-log-db ()
  (with-open-database (db "/home/stibear/Downloads/ss.db")
    (let ((count (execute-single db "select count(*) from ss")))
      (loop for i from 2 to count do
	(let ((sentence
	       (execute-single
		db
		(format nil "select statement from ss where id=~A" i))))
	  (when (zerop (mod i 100)) (print i))
	  (execute-non-query db
			     (format nil "update ss set h_list='~S' where id=~A"
				     (h-list sentence) i)))))))

(defun make-or-drop-table-to-db (&optional (flag :make))
  (with-open-database (db log-db)
    (case flag
      (:make
       (execute-single db "create table ss (id, sentence, h_list)"))
      (:drop
       (execute-single db "drop table ss")))))

(defun query-to-db (query-string)
  (with-open-database (db "/home/stibear/Downloads/ss.db")
    (execute-to-list db query-string)))

(defun csv-to-db ()
  (let ((counter 0))
    (dolist (var skypelog)
      (let ((sentence (regex-replace-all "<.*>" (nth 2 var) "")))
	(unless (string= "" sentence)
	  (caar
	   (query-to-db
	    (format nil "insert into ss values (\"~a\", \"~a\", \"~s\")"
		    (incf counter)
		    sentence
		    (h-list sentence))))))
      (if (= 0 (mod counter 1000)) (print counter)))
    counter))

(defun update-to-db ()
  (loop for i from 1 to (caar (query-to-db "select count(*) from ss"))
     do (progn
	  (query-to-db
	   (format nil "update ss set h_list='~s' where id=\"~a\""
		   (h-list
		    (caar (query-to-db
			   (format nil "select statement from ss where id=\"~a\""
				   i))))
		   i))
	  (when (= 0 (mod i 1000))
	    (print i)))))

(defun push-to-db (sentence h-list)
  (with-open-database (db log-db)
    (unless (string= "" sentence)
      (caar
       (query-to-db
	(format nil "insert into ss values (\"~a\", \"~a\", \"\", \"~s\")"
		(1+ (caar (query-to-db "select count(id) from ss")))
		sentence
		h-list))))))
