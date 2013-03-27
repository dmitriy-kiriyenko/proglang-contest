;;;
;;; sbcl --script phones.lisp
;;;

(declaim (optimize (speed 3) (space 0) (debug 0)))

(let ((letters-map (make-hash-table)))
  (flet ((letter (val &rest chars)
	   (dolist (ch chars)
	     (setf (gethash (char-upcase ch) letters-map) val
		   (gethash (char-downcase ch) letters-map) val))))
    (letter 2 #\a #\b #\c)
    (letter 3 #\d #\e #\f)
    (letter 4 #\g #\h #\i)
    (letter 5 #\j #\k #\l)
    (letter 6 #\m #\n #\o)
    (letter 7 #\p #\q #\r #\s)
    (letter 8 #\t #\u #\v)
    (letter 9 #\w #\x #\y #\z))

  (defun translate-letter (letter)
    (or (gethash letter letters-map)
	(error "Bad character"))))

(defstruct node
  word
  next)

(defun new-node ()
  (make-node :next (make-array 10 :initial-element nil)))

(defun next-node (node char)
  (svref (node-next node)
	 (translate-letter char)))

(defun set-next-node (node char n)
  (setf (svref (node-next node)
	       (translate-letter char))
	n))

(defsetf next-node set-next-node)

(defun get-or-create-next-node (node char)
  (let ((next (next-node node char)))
    (if next
	next
	(setf (next-node node char)
	      (new-node)))))

(defun tree-add-word (tree word)
  (ignore-errors
    (loop
       with node = tree
       for ch across word
       do 
	 (setf node
	       (get-or-create-next-node node ch))
       finally (pushnew word (node-word node)))))

(defmacro do-lines ((line filename) &body body)
  (let ((stream (gensym)))
    `(with-open-file (,stream ,filename
			      :direction :input
			      :if-does-not-exist :error)
       (loop
	  for ,line = (read-line ,stream nil)
	  while ,line
	  do (when (> (length ,line) 0)
	       ,@body)))))

(defun load-dictionary (filename)
  (let ((tree (new-node)))
    (do-lines (line filename)
      (tree-add-word tree line))
    tree))
  
(defun to-digits (number)
  (mapcar (lambda (ch)
	    (- (char-code ch) (char-code #\0)))
	  (coerce number 'cons)))

(defstruct solution tree)

(defun find-words (tree phone-str)
  (labels ((advance (node phone words)
	     (if phone
		 (let ((next-node (svref (node-next node) (car phone))))
		   (when next-node
		     (append
		      (advance next-node (cdr phone) words)
		      (when (node-word next-node)
			(advance tree (cdr phone) (cons (node-word next-node) words))))))
		 (when (node-word node)
		   (list
		    (make-solution :tree (reverse
					  (cons
					   (node-word node)
					   words))))))))
    (advance tree (to-digits phone-str) nil)))

(defun expand-solution (solution)
  (labels ((part (p)
	     (if p
		 (mapcan (lambda (r)
			   (mapcar (lambda (h) (cons h r))
				   (car p)))
			 (part (cdr p)))
		 (list nil))))
    (part (solution-tree solution))))

(defun print-solution (phone solution stream)
  (dolist (words (expand-solution solution))
    (format stream "~A~{ ~A~}~%" phone words)))

(defun main (dictionary input output)
  (with-open-file (ostream output
			   :direction :output
			   :if-exists :overwrite
			   :if-does-not-exist :create)
    (let ((tree (load-dictionary dictionary)))
      (do-lines (phone input)
	(let ((solutions (find-words tree phone)))
	  (dolist (solution solutions)
	    (print-solution phone solution ostream)))))))

(time (main "../dictionary.txt" "../input.txt" "../output.txt"))

