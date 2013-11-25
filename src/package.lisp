(eval-when (:compile-toplevel :load-toplevel :execute)
  (declaim (sb-ext:muffle-conditions style-warning)))

(defpackage :chatai-tan
  (:use :cl :cl-ppcre :dbus :cl-csv :trivial-shell :sqlite)
  (:export :chatai))
(in-package :chatai-tan)

(defparameter skypelog "")
(defparameter npca-room "#mine_studio/$hiromu1996;213de635c3110ed4")
(defparameter raebitsroom "#stibear/$raebits;37a0e501334f1cd0")
(defparameter chatai-directory "/home/stibear/LispProjects/chatai-tan/")
(defparameter log-db
	      (concatenate 'string chatai-directory "chatailog"))
(defparameter ss-db "/home/stibear/Downloads/ss.db")
(defparameter wikipedia-dic
	      "/home/stibear/Downloads/mecab_dic/mecab_dic/user.dic")
(defparameter my-name "tgyoza")
(defparameter random-denominator 5)
(defparameter stibear-tgyoza-room "#tgyoza/$stibear;b362485d8307664")
(defparameter chatai-room "#stibear/$8f156fa0ca618aeb")
(defparameter random-extract 1000)
