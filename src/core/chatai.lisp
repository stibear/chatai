(in-package :chatai-tan)

(defun prime-sentence (h-list)
  (let* ((sentence-prime
	  (car (get-ary (1+ (max-cdr (h-alist h-list))))))
	 (meishi-ps (choose-meishi sentence-prime)))
    (if meishi-ps
	(values sentence-prime meishi-ps)
	(prime-sentence h-list))))

(defun h-alist (h-list)
  (mapcar
   (lambda (n) (cons (scoring-h-list h-list (first n)) (second n)))
   (mapcar
    (lambda (n)
      (list (cadr (get-ary n)) n))
    (random-num-list random-extract))))

(defun chatai (string &key (mode :release))
  (let* ((sentence (regex-replace-all "<.*>" string ""))
	 (h-list (h-list sentence))
	 (sentence-prime)
	 (meishi-ps)
	 (meishi (choose-meishi sentence)))
    (unless (eq mode :debug) (push-to-db sentence h-list))
    (when h-list
      (multiple-value-bind (s-p m-ps) (prime-sentence h-list)
	(setf sentence-prime s-p meishi-ps m-ps)))
    (when (and meishi-ps meishi)
      (regex-replace-all
       meishi-ps
       sentence-prime
       meishi))))

(defun random-num-list (n)
  (let ((random-arg (length ary)))
    (loop for i to (1- n)
       collect (random random-arg (make-random-state t)))))

(defun run-mecab (string)
  (with-input-from-string (in string)
    (shell-command (format nil "mecab -u ~A" wikipedia-dic)
		   :input in)))

(defun mecab (string)
  (with-input-from-string (in (run-mecab string))
    (loop for i = (read-line in) until (string= "EOS" i)
       collect
	 (register-groups-bind
	     (hyoso hinshi rest)
	     ("(.*)\\t(.*?),(.*)" i)
	   (list hyoso hinshi rest)))))

(defun sentence-alist (string)
  (mapcar #'(lambda (str) (cons (car str) (cadr str)))
	  (mecab string)))

(defun choose-meishi (sentence)
  (let ((tmp (mapcar #'identity
		     (loop for i in (sentence-alist sentence)
			when (and (equal "名詞" (cdr i))
				  (not (and (scan "[ぁ-ゞ\x20-\x7E]+" (car i))
					    (= 1 (length (car i))))))
			collect (car i)))))
    (nth (if (not (zerop (length tmp)))
	     (random (length tmp) (make-random-state t))
	     0)
	 tmp)))

(defun max-cdr (alist)
  (let ((tmp (cdar alist)))
    (labels ((rec (alist max-num)
	       (cond ((null alist) tmp)
		     ((< max-num (caar alist))
		      (setf tmp (cdar alist))
		      (rec (cdr alist) (caar alist)))
		     (t (rec (cdr alist) max-num)))))
      (rec alist 0))))

(defun two-strings (string)
  (labels ((rec (string a b)
	     (if (= b (1+ (length string)))
		 nil
		 (cons (subseq string a b)
		       (rec string (1+ a) (1+ b))))))
    (if (= 1 (length string))
	(list string)
	(rec string 0 2))))

(defun h-list (sentence)
  (mappend #'two-strings
	   (all-matches-as-strings "[ぁ-ゞァ-ヾ,、.。]+" sentence)))

(defun scoring-h-list (h-list1 h-list2)
  (if (or (null h-list1) (null h-list2))
      -1000
      (/ (list-length (intersection h-list1 h-list2 :test #'equal))
	 (list-length h-list2))))
