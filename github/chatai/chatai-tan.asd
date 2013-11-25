#|
  This file is a part of chatai-tan project.
  Copyright (c) 2013 stibear
|#

#|
  Author: stibear
|#

(in-package :cl-user)
(defpackage chatai-tan-asd
  (:use :cl :asdf))
(in-package :chatai-tan-asd)

(defsystem chatai-tan
  :version "0.1"
  :author "stibear"
  :license "BSD License"
  :depends-on (:cl-ppcre
               :dbus
               :cl-csv
               :sqlite
               :trivial-shell)
  :components ((:module "src"
                :components
                ((:file "package")
		 (:module "util"
			  :components
			  ((:file "utility")
			   (:file "db"))
			  :depends-on ("package"))
		 (:module "core"
			  :components
			  ((:file "chatai")
			   (:file "skype"
				  :depends-on ("chatai")))
			  :depends-on ("package" "util")))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op chatai-tan-test))))
