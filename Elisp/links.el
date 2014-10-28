;;; links.el --- links browser integration for GNU Emacs

;; $Id: $

;; Copyright (C) 2000-2003 Free Software Foundation, Inc.
;; Copyright (C) 2000-2003 Kevin A. Burton (address@hidden)

;; Author: Kevin A. Burton (address@hidden)
;; Maintainer: Kevin A. Burton (address@hidden)
;; Location: http://relativity.yi.org
;; Keywords: 
;; Version: 1.0.0

;; This file is [not yet] part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.
;;
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, write to the Free Software Foundation, Inc., 59 Temple
;; Place - Suite 330, Boston, MA 02111-1307, USA.

;;; Commentary:

;; NOTE: If you enjoy this software, please consider a donation to the EFF
;; (http://www.eff.org)

;; This package provides integration for the 'links' browser with Emacs
;; (http://links.sourceforge.net).  Links is a great browser, much better than
;; 'lynx' (IMO).  It supports frames and tables which are basically a
;; requirement now that HTML 4.0 is pretty much everywhere..
;;
;; The integration here is important especially when compared to W3.  W3 has
;; performance problems when rendering tables and frames.  links.el and links
;; does not have this problem and in fact is blazingly fast.
;;
;; links.el supports the following features.
;;
;; - uses customization for all important variables.
;;
;; - links-browse-url supports two types of behavior
;;
;;   - browse within xterm
;;   -  browse within buffer
;;
;; - support for launching links within an xterm.  This can be done with
;;
;; - specify geomoetry, width and height,  for the xterm
;;
;; - supports 'dump' integration so that we can save to a *links* buffer
;; directly within emacs.
;;
;; - ability to jump from the links buffer to a links xterm.

;;; Code:

(defcustom links-browse-type (list "within xterm")
  "Type of browsing metaphor.  Within an xterm or within a buffer."
  :group 'links
  :type '(list
          (radio-button-choice
           (item "within xterm")
           (item "within buffer"))))

(defcustom links-xterm-geom "100x60+0+0" "Width of launch xterms."
  :group 'links
  :type 'string)

(defvar links-browse-buffer-name "*links*"
  "Buffer name used for browsing links within a buffer.")

(defvar links-browse-buffer-url nil "Used to store the URL for the currently 
visited links URL.")

(defun links-browse-url(url)
  "Browse the given URL within the 'links' browser."
  (interactive
   (list
    (read-string "URL: ")))

  (let((type (nth 0 links-browse-type)))

    (if (string-equal type "within xterm")
        (links-browse-url-within-xterm url)
      (if (string-equal type "within buffer")
          (links-browse-url-within-buffer url)
        (error "Unable to handle browse type: %s" type)))))

(defun links-browse-url-within-xterm(url)
  "Browse the given URL within the 'links' browser under a dedicated xterm."
  (interactive
   (list
    (read-string "URL: ")))

  (start-process "links" nil "xterm" "-geom" links-xterm-geom "-e" "links" url))

(defun links-browse-url-within-buffer(url)
  "Browse the given URL within the 'links' browser under a dedicated Emacs
  buffer.  Note that in a lot of situations this may not be ideal.  For HTML
  documents that use frames or large tables the output may be distorted within
  an Emacs buffer.  It is also not possible to 'browse' within the buffer - you
  can not jump to any new links."
  (interactive
   (list
    (read-string "URL: ")))

  (let(buffer)

    (setq buffer (get-buffer-create links-browse-buffer-name))

    (save-excursion

      (set-buffer buffer)

      ;;keep this here so that it can be buffer local.
      (setq links-browse-buffer-url url)
      
      (erase-buffer))

    ;;needs to be a synchronous process so that the output doesn't scroll
    (call-process "links" nil buffer nil "-dump" url)

    (show-buffer (selected-window) buffer)

    (set-window-point (selected-window) (point-min))))

(defun links-browse-last-buffer-url-within-xterm()
  "Browse the links buffer URL within an xterm.  This is very handy because once
  in an xterm we can link to other documents, use history, goto other sites,
  etc."
  (interactive)

  (if links-browse-buffer-url
      (links-browse-url-within-xterm links-browse-buffer-url)
    (error "No buffer URL to browse")))

(defun browse-url-links(url &optional new-window)
  "`browse-url' compatible version of links-browse-url"
  (interactive
   (list
    (read-string "URL: ")))

  (links-browse-url url))

(provide 'links)

;;; links.el ends here
