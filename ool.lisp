;;;;Zheng Lei Maurizio 866251
;;;;Moretti Simone 894672
;;;;Marini Filippo 900000

;;; -*- Mode: Lisp -*-

;;; ool.lisp

(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

(defun class-spec (name)
  (gethash name *classes-specs*))


;;;Definisce una classe
(defun def-class (class-name parents &rest part)
  ;;controllo: se class-name e' una classe gia' esistente
  ;;se class-name e' un atomo
  ;;e se parents e' una lista di classi valide
  (cond ((is-class class-name) (error "Classe gia' creata"))
        ((not (atom class-name)) (error "Class name non e' atomo"))
        ((not (and (listp parents)
                   (is-class-list parents)))
         (error "Parents non sono delle classi genitori valide"))
        ((not (equal parents (remove-duplicates parents)))
         (error "Parents hanno 2 classi uguali")))
  (add-class-spec
   class-name
   (append (list class-name)
           (append (list parents)
                   (remove nil (insert-part parents part)))))
  ;;per stampare alla fine il nome della classe
  class-name
)

;;;divide i part in fields e methods, e li gestisce in altre funzioni
;;;tiene i parents per controllare le superclassi
(defun insert-part (parents part)
  (cond 
   ((zerop (list-length part)) nil)
   ;;se part sono i fields
   ((equal (car (car part)) 'fields)
    (duplicate-parts-check (cdr (car part)) (cdr (car part)))
    (cons (append (list 'fields)
                  (list (insert-fields parents (cdr (car part)))))
          (insert-part parents (cdr part))))
   ;;se part sono i metodi
   ((equal (car (car part)) 'methods)
    (duplicate-parts-check (cdr (car part)) (cdr (car part)))
    (cons (append (list 'methods)
                  (list (insert-methods (cdr (car part)))))
          (insert-part parents (cdr part))))))



;;;da lista di field, concatena il primo con il resto, ricorsivamente
;;;il primo viene gestito in un altra funzione
;;;il resto dei fields viene rimandato qui
(defun insert-fields (parents fields)
  (cond ((null fields) nil)
        (t (cons (control-field parents (car fields))
                   (insert-fields parents (cdr fields))))))


;;;controlla che il field rispetti i vincoli del suo type
;;;e che il type rispetti quelli dei parents
(defun control-field (parents field)
  (cond
   ;;field e' solo un simbolo
   ((atom field)
    ;;richiamo la funzione mettendo field in una lista
    (control-field parents (list field nil)))
   ;;controlla la lunghezza di field
   ;;se non rispetta i parametri, da errore
   ((or (< (list-length field) 2)
         (> (list-length field) 3))
    (error
     "Field ~S non rispetta la forma '(' <name> <value> [<type>] ')'"
     field))
   ;;parents e type nil
   ((and (null parents)
         (null (third field)))
    ;;se il valore e' nil, appende field con nil e t
      ;;altrimenti, appende field con t
      (append field (list T)))
   
   ;;parents nil e type presente
   ((null parents)
    (cond
     ((cond
       ;;se il type e' una classe, se lo e', verifica 
       ((is-class (third field))
        ;;se il valore sia un'istanza della (super)classe
        (if (is-instance (second field))
            (is-instance (second field) (third field))
          (is-instance (eval (second field)) (third field))))
       ;;se il type non e' una classe, verifica
       ;;se il type del valore sia subtype del type dichiarato
       ((subtypep (type-of (second field)) (third field))))
      ;;se uno dei due casi e' corretto, ritorna field
      field)
     (t (error
         "Field ~S non rispetta i parametri del suo type"
         field)))) 
   
   ;;type nil e parents presente
   ((null (third field))
    (cond
     ((cond
       ;;cerca il field nei genitori
       ((field-superclass parents (car field))
        ;;se lo trova, ne controlla il type
        (cond
         ;;se e' una classe, verifica se field sia una sua istanza
         ((is-class (third (field-superclass parents (car field))))
          (if (is-instance (second field))
              (is-instance
               (second field)
               (third (field-superclass parents (car field))))
            (is-instance
             (eval (second field))
             (third (field-superclass parents (car field))))))
         ;;se non e' una classe, verifica
         ;;se il type del del valore sia subtype del type genitore
         ((subtypep
           (type-of (second field))
           (third (field-superclass parents (car field)))))))
       ;;se non trova il field nei genitori, ritorna solo T
       (t t))
      ;;se uno dei casi sopra e' vero
      ;;appende una lista del primo e secondo elemento di field
      ;;(se viene passato come field una lista con solo un simbolo)
      ;;o con il type del genitore, o con T
      (append
       field
       (list (or (third (field-superclass parents (car field))) t))))
     (t (error
         "Field ~S non rispetta i parametri dei parents"
         field))))
   
   ;;parents e type presenti
   ((cond
     ;;cerca il field nei genitori:
     ((field-superclass parents (car field))
      ;;se lo trova, ne controlla il type:
      (cond
       ;;se type genitore e' una classe, verifica
       ((is-class (third (field-superclass parents (car field))))
        ;;se field sia della classe passata come type, e
        (and (if (is-instance (second field))
                 (is-instance (second field) (third field))
               (is-instance (eval (second field)) (third field)))
             ;;se il type dichiarato sia una sottoclasse del genitore
             (is-child (third field)
                       (third
                        (field-superclass parents (car field))))))
       ;;se type genitore non e' una classe, verifica
       ;;se il type del valore sia subtype del type dichiarato, e
       ;;se il type dichiarato sia un subtype del type genitore;
       ((and (subtypep (type-of (second field)) (third field)))
        (subtypep (third field)
                  (third
                   (field-superclass parents (car field)))))))
     ;;se non trova il field nei genitori, ritorna T;
     (t t))
    ;;se uno di questi casi e' vero, ritorna field
    field)
   (T (error "Field ~S non rispetta il subtype" field))))


;;;da lista di metodi, concatena il primo con il resto, ricorsivamente
;;;concatena un cons con nome del primo metodo e la sua funzione
;;;il resto dei metodi viene rimandato qui
(defun insert-methods (methods)
  (cond
   ((null methods) nil)
   (t (cons (cons (car (car methods))
                  (process-method (car (car methods))
                                  (cdr (car methods))))
            (insert-methods (cdr methods))))))

;;;crea una funzione lambda e la attribuicse al nome del metodo
;;;la funzione lambda cerca il nome del metodo tra
;;;i metodi delle superclassi dell'istanza chiamata
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
        (lambda (this &rest args)
          (apply 
           (cdr (get-method (class-spec (second this)) method-name))
           (append (list this) args))))
  (eval (rewrite-method-code method-spec)))

;;;riscrive il metodo in modo che prenda un this come parametro
(defun rewrite-method-code (method-spec)
  (cons 'lambda
        (cons (append (list 'this) (car method-spec))
              (cdr method-spec))))


;;;controlla se le parti vengono ripetuti in una classe o istanza
(defun duplicate-parts-check (parts-list parts-to-check)
  (cond ((null parts-to-check) nil)
        ;;;se il fiend da controllare e' solo un simbolo
        ((atom (car parts-to-check))
         ;;;richiamo la funzione mettendo il field dentro una lista
         (duplicate-parts-check parts-list
                          (cons (list (car parts-to-check))
                                      (rest parts-to-check))))
        ;;;se ne conta piu di 1, da errore
        ((> (count-part parts-list (car (car parts-to-check))) 1)
         (error "Part ~S viene ripeturo" (car (car parts-to-check))))
        (t (duplicate-parts-check parts-list (rest parts-to-check)))))

;;;conta quante volte una parte appare in una lista
(defun count-part (part-list part)
  (cond ((null part-list) 0)
        ;;;se il field di part-list da controllare e' solo un simbolo
        ((atom (car part-list))
         ;;;richiamo la funzione mettendo il field dentro una lista
         (+ 0 (count-part
               (cons (list (car part-list)) (rest part-list)) part)))
        ((equal (car (car part-list)) part)
         (+ 1 (count-part (rest part-list) part)))
        (t (+ 0 (count-part (rest part-list) part)))))


;;;crea un'istanza concatenando oolinst con i fields
;;;manda anche i fields in un altra funzione per
;;;verificase se esistono doppioni
(defun make (class-name &rest fields)
  (duplicate-parts-check (group-fields fields) (group-fields fields))
  (append
   (list 'oolinst)
   (cons class-name (list (make-fields class-name fields)))))

;;;raggruppa i fields in coppie chiave valore
;;;usato da (make) alla chiamata di (duplicate-parts-check)
;;;necessario per il corretto funzionamento di (duplicate-parts-check)
(defun group-fields (fields)
  (cond ((null fields) nil)
        (t (cons (list (car fields) (second fields))
                 (group-fields (rest (rest fields)))))))

;;;prende primo e secondo elemento dei fields
;;;(prima coppia chiave valore) e lo rimanda ad un altra funzione
;;;insieme alla classe per controllare i type
;;;il resto rimandato qui ricorsivamente
(defun make-fields (class-name fields)
  (cond ((null fields) nil)
        (t (cons
            (make-field-check (list class-name)
                        (list (car fields) (second fields)))
            (make-fields class-name (cdr (cdr fields)))))))

;;;controlla il type del valore del field con i genitori (se esistono)
(defun make-field-check (class-name field)
  (cond
   ;;check esistenza del field nella classe
   ((field-superclass class-name (car field))
    (cond
     ;;se esiste, controlla se e' una classe
     ((is-class (third (field-superclass class-name (car field))))
      (cond
       ;;se lo e', controlla che il valore sia una sua istanza
       ((is-instance
         (second field)
         (third (field-superclass class-name (car field))))
        field)
       (t (error 
           "Field ~S non e' istanza di classe valida" field))))
     ;;se non e' una classe, controlla il subtype
     ((subtypep (type-of (second field))
                (third (field-superclass class-name (car field))))
      field)
     (t (error
         "Field ~S non rispetta i vincoli della classe" field))))
   (t (error
       "Field ~S non presente nella classe" field))))

;;;Usata da (def-class)
;;;controlla ricorsivamente che class-name sia una lista di classi
(defun is-class-list (class-list)
  (cond ((zerop (list-length class-list)) t)
        (t (and (is-class (car class-list))
                (is-class-list (cdr class-list))))))

;;;controlla se class-name sia una classe
(defun is-class (class-name)
  (if (class-spec class-name) t))

;;;controlla che value sia una (sotto)istanza di una classe
;;;se class-name e' T,
;;;allora deve solo controllare che value sia un'istanza qualunque
;;;altrimenti, controlla se value sia un'istanza di class-name, oppure
;;;se value sia un'istanza di una classe
;;;avente class-name come superclasse
(defun is-instance (value &optional (class-name t))
  (if (and (listp value) (equal (car value) 'oolinst))
      (cond
       ((equal class-name t) t)
       ((equal class-name (second value)) t)
       (t
        (is-child (second (class-spec (second value)))class-name)))))

;;;controlla se class-child sia una sottoclasse di class-parent 
(defun is-child (class-child class-parent)
  (cond ((null class-child) nil)
        ;;richiama ricorsivamente se stesso
        ;;con la prima classe e il resto
        ((listp class-child)
         (or (is-child (car class-child) class-parent)
             (is-child (cdr class-child) class-parent)))
        ((atom class-child)
         ;;se la classe e' uguale a quella che stiamo cercando,
         ;;ritorna T
         ;;altrimenti controlla i genitori dei genitori
         (if (equal class-child class-parent) t
           (is-child (second (class-spec class-child))
                     class-parent)))))


;;;controlla inanzitutto che instance sia effettivamente un'instanza
(defun field (instance field-name)
  (if (is-instance instance) (field-instance instance field-name)
    (error "~S non e' un'instanza" instance)))

;;;controlla se il field e' presente nell'istanza o nelle classi
;;;da errore se non lo trova
(defun field-instance (instance field-name)
  (or (second (field-check
               (third instance) field-name (list (second instance))))
      (error "Field ~S non presente nell'istanza" field-name)))

;;;cerca l'uguaglianza tra il primo field di field-list e field-name
;;;se lo trova, ritorna il field trovato
;;;altrimenti, lo cerca tra il resto dei field-list
;;;se non e' presente in field-list, cerca tra i parents
(defun field-check (field-list field-name parents)
  (cond ((null field-list) (field-superclass parents field-name))
        ((equal (car (car field-list)) field-name) (car field-list))
        (t (field-check (cdr field-list) field-name parents))))

;;;controlla prima la prima classe 
;;;dopo, se non ha trovato il field lo cerca
;;;nel resto delle classi richiamate ricorsivamente qui
(defun field-superclass (classes field-name)
  (cond ((null classes) nil)
        (t (or (field-class-location
                (class-spec (car classes)) field-name)
               (field-superclass (cdr classes) field-name)))))

;;;controlla la posizione dei fields nella classe
;;;se non la trova, procede con i parents
(defun field-class-location (class field-name)
  (cond ((equal (car (third class)) 'fields)
         (field-check (second (third class))
                      field-name (second class)))
        ((equal (car (fourth class)) 'fields)
         (field-check (second (fourth class))
                      field-name (second class)))
        (t (field-superclass (second class) field-name))))


;;;ricerca una serie di field in sequenza
;;;codice diviso in due casi:
;;;se instance e' una lista, viene si prosegue normalmente
;;;altrimenti (e' un simbolo), si prosegue con il suo eval
(defun field* (instance &rest field-name)
  (cond ((not (listp field-name))
         (error "~S non e' una lista" field-name))
        ;;controlla se instance sia un'istanza (in qualsiasi forma)
        ((not (or (is-instance instance)
                  (is-instance (eval instance))))
         (error "~S non e' un'istanza" instance))
        ;;se rimane solo un field-name
        ((= (list-length field-name) 1)
         (if (is-instance instance)
             (field-instance instance (car field-name))
           (field-instance (eval instance) (car field-name))))
        ;;ricorsione se ci sono piu' field-name
        (t (if (is-instance instance)
               (field* (field-instance instance (car field-name))
                       (car (cdr field-name)))
             (field* (field-instance (eval instance) (car field-name))
                     (car (cdr field-name)))))))

;;;cerca se esiste un metodo method-name nella classe class
;;;se non la trova, da errore
(defun get-method (class method-name)
  (or (method-class-location class method-name)
      (error "~A non e' un metodo valido per l'istanza" method-name)))

;;;cerca l'uguaglianza tra il primo di method-list e method-name
;;;se lo trova, ritorna il metodo trovato
;;;altrimenti, lo cerca tra il resto di method-list
;;;se non e' presente in method-list, cerca tra i parents
(defun method-check (method-list method-name parents)
  (cond ((null method-list) (method-superclass parents method-name))
        ((equal (car (car method-list)) method-name)
         (car method-list))
        (t (method-check (cdr method-list) method-name parents))))

;;;controlla prima la prima classe 
;;;dopo, se non ha trovato il metodo lo cerca
;;;nel resto delle classi richiamate ricorsivamente qui
(defun method-superclass (classes method-name)
  (cond ((null classes) nil)
        (t (or (method-class-location
                (class-spec (car classes)) method-name)
               (method-superclass (cdr classes) method-name)))))

;;;controlla la posizione dei metodi nella classe
;;;se non la trova, procede con i parents
(defun method-class-location (class method-name)
  (cond ((equal (car (third class)) 'methods)
         (method-check (second (third class))
                       method-name (second class)))
        ((equal (car (fourth class)) 'methods)
         (method-check (second (fourth class))
                       method-name (second class)))
        (t (method-superclass (second class) method-name))))


;;; end of file --- ool.lisp