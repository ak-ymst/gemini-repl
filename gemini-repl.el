(defvar gemini-api-key (getenv "GENINI_API_KEY"))

(defun gemini-send-request (input-text)
  "Send INPUT-TEXT to Gemini and return the response."
  (let ((url "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText")
        (url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/json")))
        (url-request-data (json-encode `(("prompt" . (("text" . ,input-text)))))))
    (with-current-buffer (url-retrieve-synchronously (concat url "?key=" gemini-api-key))
      (goto-char (point-min))
      (if (search-forward "{" nil t)
          (let* ((json-object-type 'alist)
                 (json-array-type 'list)
                 (json-key-type 'string)
                 (json-data (json-read-from-string (buffer-substring-no-properties (point) (point-max)))))
            (cdr (assoc "output" (elt (cdr (assoc "candidates" json-data)) 0))))
        "No response from Gemini"))))

(defun gemini-login-gcloud ()
  "Attempt to log in to Google Cloud."
  (interactive)
  (let ((output (shell-command-to-string "gcloud auth login --brief")))
    (if (string-match "You are now logged in" output)
        "Login successful"
      "Login failed or requires manual interaction")))

(defun gemini-repl ()
  "Start a simple REPL for interacting with Gemini."
  (interactive)
  (switch-to-buffer "*Gemini REPL*")
  (erase-buffer)
  (insert "> ")
  (local-set-key (kbd "RET") #'gemini-repl-submit))

(defun gemini-repl-submit ()
  "Handle user input and display Gemini's response."
  (interactive)
  (let ((input (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
    (goto-char (point-max))
    (insert "\n")
    (insert (gemini-send-request (string-trim (substring input 2))))
    (insert "\n> ")))

(provide 'gemini-repl)
