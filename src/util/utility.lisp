(in-package :chatai-tan)

(defun mappend (fn &rest lsts)
  (apply #'append (apply #'mapcar fn lsts)))

(defun group (source n)
  (if (zerop n) (error "zero length"))
  (labels ((rec (source acc)
	     (let ((rest (nthcdr n source)))
	       (if (consp rest)
		   (rec rest (cons
			      (subseq source 0 n)
			      acc))
		   (nreverse
		    (cons source acc))))))
    (if source (rec source nil) nil)))

(defmacro defparameters (&rest args)
  `(values
     ,@(mapcar (lambda (a) `(defparameter ,@a))
	       (group args 2))))

(defmacro error-logging-file ((logfile &rest keys) &body forms)
  (let ((file (gensym)))
    `(with-open-file (,file ,logfile ,@keys)
       (handler-case
	   (progn ,@forms)
	 (error (e)
	   (format ,file "~%ERROR: ~a" e))))))

(defmacro style-warning-suppressor (&rest body)
  `(handler-bind ((style-warning #'muffle-warning))
     ,@body))

(defmacro dprint (hint &rest obj)
  (let ((objlist (cons 'list (loop for i in obj append (list (list 'quote i)
							      i)))))
    `(progn (format t "<debug (~S)>:~%~{~3@T~S: ~S~%~^~}"
		    ,hint
		    ,objlist)
	    (values ,@obj))))

(defun set-member-r (item set &key (test #'eql))
  (let ((tmp (member item (car set) :test test)))
    (cond
      ((null set) nil)
      ((not (null tmp)) tmp)
      (t (set-member item (cdr set) :test test)))))

(defun set-member (item set &key (test 'eql))
  (member item set :test (lambda (n m) (member n m :test test))))

(defun whath (item list &key (test #'eql))
  (labels
      ((acc (item set n)
	 (cond ((null set) nil)
	       ((funcall test item (car set)) n)
	       (t (acc item (cdr set) (1+ n))))))
    (acc item list 0)))

(defun set-whath (item set &key (test 'eql))
  (whath item set
	 :test (lambda (n m) (funcall #'member n m :test test))))

(defmacro aif (test-form then-form &optional else-form)
  `(let ((it ,test-form))
     (if it ,then-form ,else-form)))

(defmacro awhen (test &body form)
  `(let ((it ,test))
     (when it ,@form)))

(defun dic-append (name str1 str2 str3)
  (with-open-file (out (concatenate 'string chatai-directory
				    "dic/wikipedia.dic")
		       :direction :output
		       :if-exists :append)
    (format out "~&~A,*,*,2000,名詞,固有名詞,人名,*,*,*,~A,~A,~A"
	    name str1 str2 str3)))
