;;   The Computer Language Benchmarks Game
;;   http://benchmarksgame.alioth.debian.org/
;;;
;;; contributed by Manuel Giraud
;;; modified by Nicolas Neuss
;;; modified by Juho Snellman 2005-10-26
;;;
;;; modified by Witali Kusnezow 2009-01-20
;;;  * simplified structure of leaf nodes
;;;  * optimize GC usage
;;;  * optimize all functions
;;;
;;; modified by Witali Kusnezow 2009-08-20
;;;  * remove GC hacks to satisfy new versions of the sbcl
;;;
;;; modified by Marko Kocic 2011-02-18
;;;  * add declaim to optimize for speed
;;;
;;; modified by Wukix to run on mocl
;;;  * Run non-standard purify function only on SBCL
;;;  * Made output a string (standard output is not readily available on Android)
;;;
;;; Node is either (DATA) (for leaf nodes) or an improper list (DATA LEFT . RIGHT)

(declaim (optimize (speed 3) (debug 0) (space 0) (safety 0)))
#-mocl (declaim (declaration call-in))

(defun build-btree (item depth)
  (declare (fixnum item depth))
  (if (zerop depth) (list item)
      (let ((item2 (+ item item))
            (depth-1 (1- depth)))
        (declare (fixnum item2 depth-1))
        (cons item
              (cons (build-btree (the fixnum (1- item2)) depth-1) 
                      (build-btree item2 depth-1))))))

(defun check-node (node)
  (declare (values fixnum))
  (let ((data (car node))
        (kids (cdr node)))
    (declare (fixnum data))
    (if kids
        (- (+ data (check-node (car kids)))
           (check-node (cdr kids)))
        data)))

(defvar *s* nil)

(defun loop-depths (max-depth &key (min-depth 4))
  (declare (type fixnum max-depth min-depth))
  (loop for d of-type fixnum from min-depth by 2 upto max-depth do
       (loop with iterations of-type fixnum = (ash 1 (+ max-depth min-depth (- d)))
          for i of-type fixnum from 1 upto iterations
          sum (+ (the fixnum (check-node (build-btree i d)))
                 (the fixnum (check-node (build-btree (- i) d))))
          into result of-type fixnum
          finally
            (format *s* "~D trees of depth ~D check: ~D~%"
                    (the fixnum (+ iterations iterations)) d result))))

(declaim (call-in binary-trees))
(defun binary-trees (n)
  (declare (type (integer 0 255) n))
  (with-output-to-string (s) 
    (setf *s* s)
    (format s "stretch tree of depth ~D check: ~D~%" (1+ n) (check-node (build-btree 0 (1+ n))))
    (let ((*print-pretty* nil) (long-lived-tree (build-btree 0 n)))
      #+sbcl (purify)
      (loop-depths n)
      (format s "long lived tree of depth ~D check: ~D~%" n (check-node long-lived-tree)))))
