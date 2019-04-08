;;; funcs.el --- Javascript Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Muneeb Shaikh <muneeb@reversehack.in>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3


;; backend

(defun spacemacs//js-setup-backend ()
  "Conditionally setup javascript backend."
  (pcase javascript-backend
    (`dumb (spacemacs//js-setup-dumb))
    (`lsp (spacemacs//js-setup-lsp))))

(defun spacemacs//js-setup-company ()
  "Conditionally setup company based on backend."
  (pcase javascript-backend
    (`dumb (spacemacs//js-setup-dumb-company))
    (`lsp (spacemacs//js-setup-lsp-company))))

(defun spacemacs//js-setup-next-error-fn ()
  (setq-local next-error-function nil))

;; lsp

(defun spacemacs//js-setup-lsp ()
  "Setup lsp backend."
  (if (configuration-layer/layer-used-p 'lsp)
      (progn
        ;; error checking from lsp langserver sucks, turn it off
        (setq-local lsp-prefer-flymake :none)
        (lsp))
        ;; (flycheck-select-checker 'javascript-eslint))
    (message (concat "`lsp' layer is not installed, "
                     "please add `lsp' layer to your dotfile."))))

(defun spacemacs//js-setup-lsp-company ()
  "Setup lsp auto-completion."
  (if (configuration-layer/layer-used-p 'lsp)
      (progn
        (spacemacs|add-company-backends
          :backends company-lsp
          :modes js2-mode
          :append-hooks nil
          :call-hooks t)
        (company-mode)
        (fix-lsp-company-prefix))
    (message (concat "`lsp' layer is not installed, "
                     "please add `lsp' layer to your dotfile."))))


;; dumb
(defun spacemacs//js-setup-dumb ()
  (add-to-list 'spacemacs-jump-handlers-js2-mode 'dumb-jump-go))

(defun spacemacs//js-setup-dumb-company ()
  (spacemacs|add-company-backends :backends company-capf :modes js2-mode))


;; import-js

(defun spacemacs/import-js-set-key-bindings (mode)
  "Setup the key bindings for `import-js' for the given MODE."
  (spacemacs/declare-prefix-for-mode mode "mi" "import")
  (spacemacs/set-leader-keys-for-major-mode mode
    "if" #'spacemacs/import-js-fix
    "ii" #'spacemacs/import-js-import
    "gi" #'import-js-goto))

(defun spacemacs/import-js-fix ()
  (interactive)
  (require 'import-js)
  (import-js-fix)
  (if (bound-and-true-p flycheck-mode)
      (flycheck-buffer)))

(defun spacemacs/import-js-import ()
  (interactive)
  (require 'import-js)
  (import-js-import)
  (if (bound-and-true-p flycheck-mode)
      (flycheck-buffer)))


;; js-doc

(defun spacemacs/js-doc-require ()
  "Lazy load js-doc"
  (require 'js-doc))
(add-hook 'js2-mode-hook 'spacemacs/js-doc-require)

(defun spacemacs/js-doc-set-key-bindings (mode)
  "Setup the key bindings for `js2-doc' for the given MODE."
  (spacemacs/declare-prefix-for-mode mode "mrd" "documentation")
  (spacemacs/set-leader-keys-for-major-mode mode
    "rdb" 'js-doc-insert-file-doc
    "rdf" (if (configuration-layer/package-used-p 'yasnippet)
              'js-doc-insert-function-doc-snippet
            'js-doc-insert-function-doc)
    "rdt" 'js-doc-insert-tag
    "rdh" 'js-doc-describe-tag))

;; js-refactor

(defun spacemacs/js2-refactor-require ()
  "Lazy load js2-refactor"
  (require 'js2-refactor))


;; skewer

(defun spacemacs/skewer-start-repl ()
  "Attach a browser to Emacs and start a skewer REPL."
  (interactive)
  (run-skewer)
  (skewer-repl))

(defun spacemacs/skewer-load-buffer-and-focus ()
  "Execute whole buffer in browser and switch to REPL in insert state."
  (interactive)
  (skewer-load-buffer)
  (skewer-repl)
  (evil-insert-state))

(defun spacemacs/skewer-eval-defun-and-focus ()
  "Execute function at point in browser and switch to REPL in insert state."
  (interactive)
  (skewer-eval-defun)
  (skewer-repl)
  (evil-insert-state))

(defun spacemacs/skewer-eval-region (beg end)
  "Execute the region as JavaScript code in the attached browser."
  (interactive "r")
  (skewer-eval (buffer-substring beg end) #'skewer-post-minibuffer))

(defun spacemacs/skewer-eval-region-and-focus (beg end)
  "Execute the region in browser and swith to REPL in insert state."
  (interactive "r")
  (spacemacs/skewer-eval-region beg end)
  (skewer-repl)
  (evil-insert-state))
