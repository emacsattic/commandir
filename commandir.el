;;; commandir.el -- Directory Commander
;;
;; Copyright (C) 2009 Sebastian Tennant
;;
;; Author:     Sebastian Tennant <sebyte@gmail.com>
;; Maintainer: Sebastian Tennant <sebyte@gmail.com>
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
;;
;; commandir.el is not part of GNU Emacs.

;;; Commentary:
;;
;;   I think you'll agree this macro is handy.
;;
;;   Call it with arguments of your choosing to define interactive
;;   commands that either provide instant access to existing files in
;;   a specified directory, or return named buffers which will be
;;   written to files (with the same name) within the same specified
;;   directory.
;;
;;   The first argument to the macro call is the name of interactive
;;   command you want to able to issue.
;;
;;   The second argument is the string to be displayed when prompted
;;   for a file name.
;;
;;   The third argument is the name of a default file which will be
;;   visited if you don't provide a file name when prompted, .i.e.,
;;   you just hit RET.
;;
;;   Unless the fourth argument to the macro call is 'stack (a symbol)
;;   point will move to the end of the buffer immediately after the
;;   file is visited.
;;
;;   If the fifth argument (the last) to the macro call is non-nil,
;;   a pretty date-time stamp is inserted at point's final position.
;;
;;   Finally, if a file named '.template' is found in the specified
;;   directory, its contents are automatically inserted when a new
;;   file is created and any file local variables it may conatin are
;;   evaluated.

;;; Installation:
;;
;;   Put this file somewhere in your load-path and add the line:
;;
;;    (require 'commmandir)
;;
;;   to your ~/.emacs.   Then add calls to commandir, e.g.,
;;
;;    (commandir memo "Memo subject: " "~/memo" "misc" 'stack)
;;
;;  When Emacs has loaded you can then type 'M-x memo RET' to compose a
;;  new memo or edit an old one.


;;; commandir.el begins here

(defvar commandir-date-format "%a %d %b %Y %l:%M %p%n%n")
(defvar commandir-date-prefix "* ") ; useful for outline-mode e.t.c.

(defmacro commandir (call pmt dir def &optional type date)
 `(defun ,call ()
    (interactive)
    (let ((dir/ (file-name-as-directory ,dir)) ; ensure final '/'
          filename insert-default-directory) ; nil
      (setq filename (read-file-name ,pmt dir/))
      (when (equal filename "") (setq filename ,def))
      ;; find-file automatically selects buffer for editing
      (find-file (concat dir/ filename) nil)
      (when (eq (buffer-size) 0) ; buffer empty?
        ;; insert template file and evaluate local-variables
        (if (file-readable-p (concat dir/ ".template"))
            (progn (insert-file (concat dir/ ".template"))
                   (hack-local-variables))
          (text-mode)))
      ;; position point
      (unless (equal ,type 'stack)
        (goto-char (point-max)))
      (when (eq ,date t)
        ;; insert date
        (insert commandir-date-prefix)
        (shell-command
         (format "date '+%s'" commandir-date-format) t)
        (forward-line 2))
      ;; display
      (switch-to-buffer (buffer-name)))))

(provide 'commandir)

;;; commandir.el ends here
