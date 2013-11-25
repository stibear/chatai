(in-package :chatai-tan)

(defparameter ary-path "~/array")
(defvar ary)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :cl-store))

(defun load-ary ()
  (length (setf ary (cl-store:restore ary-path))))

(defun save-ary ()
  (length (cl-store:store ary ary-path)))

(defun get-ary (n)
  (aref ary n))
