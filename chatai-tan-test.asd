#|
  This file is a part of chatai-tan project.
  Copyright (c) 2013 stibear
|#

(in-package :cl-user)
(defpackage chatai-tan-test-asd
  (:use :cl :asdf))
(in-package :chatai-tan-test-asd)

(defsystem chatai-tan-test
  :author "stibear"
  :license "BSD License"
  :depends-on (:chatai-tan
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "chatai-tan"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
