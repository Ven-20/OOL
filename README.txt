Zheng Lei Maurizio 866251
Moretti Simone 894672
Marini Filippo 900000

 _____   _____   _ 
/  _  \ /  _  \ | |
| | | | | | | | | |
| | | | | | | | | |
| |_| | | |_| | | |___
\_____/ \_____/ |_____|


Leggenda:
1) Introduzione
2) Funzioni principali
3) Funzioni di supporto
4) Esempi



1) INTRODUZIONE

OOL e' un'estensione "object oriented" di Common Lisp con eredita'
multipla.
Questa estensione permettera' a Common Lisp di creare classi e
sottoclassi, aventi dentro campi e metodi, e di creare istanze di
queste classi, con a loro volta i loro campi, ereditati dalla classe.
L'implementazione di cio' e' svolto in modo particolare, mostrando
solo i campi e metodi "nuovi" delle classi ed istanze, quindi, a meno
che non si crei un nuovo campo e/o metodo, o non si modifichi una
ereditata, il sistema non mostrera' tutti i campi e metodi
ereditati, anche se comunque presenti.



2) FUNZIONI PRINCIPALI

- DEF-CLASS

Definisce la struttura di una classe e la memorizza in una locazione
centralizzata (una variabile globale).
Ritorna <class-name>.

Sintassi:
	'(' def-class <class-name> <parents> <part>* ')'

	part	    ::= '(' fields <field>* ')'
		    |   '(' methods <method>* ')'
	field	    ::= <field-name>
		    |   '(' <field-name> <value> [<field-type>] ')'
	method	    ::= '(' <method-name> <arglist> <form>* ')'

	field-type  ::= T | <type>


<class-name> 	    e' un simbolo, definisce il nome della classe;
<parents>	    e' una lista (possibilmente vuota) di simboli,
		    sono i nomi di altre classi;
<part> 	       	    e' un insieme di campi, o un insieme di
		    definizionidi metodo. 
<field-name>	    e' un simbolo;
<value>		    e' un'espressione costante autovalutante
		    qualunque; 
<type>		    e' il nome di una classe gia' definita con
		    def-class, un tipo numerico Common Lisp, o T;
<method-name>	    e' un simbolo;
<arglist>	    e' una lista di parametri standard Common Lisp;
<form>		    e' una qualunque espressione Common Lisp;


- MAKE

Crea una nuova istanza di una classe.
Ritorna la nuova istanza di <class-name>

Sintassi:
	'(' make <class-name> [<field-name> <value>]* ')'

<class-name>	    e' un simbolo, rappresenta il nome della classe di
		    appartenenza;
<field-name>	    e' un simbolo, rappresenta il nome di un campo;
<value>		    e' un qualunque valore.


- IS-CLASS

Restituisce T se <class-name> e' il nome di una classe.

Sintassi:
	'(' is-class <class-name> ')'

<class-name>	    e' un simbolo, rappresenta il nome di una classe.


- IS-INSTANCE

Restituisce T se <value> e' l'istanza di una classe.
Se <class-name> e' T, basta che <value> sia un'istanza qualunque;
altrimenti, deve essere un'istanza di classe <class-name>, oppure
un'istanza di una classe avente <class-name> come superclasse.

Sintassi:
	'(' is-instance <value> [<class-name>] ')'

<class-name>	    e' un simbolo, rappresenta il nome di una classe;
<value>		    e' un qualunque valore.


- FIELD

Estrae il valore di un campo da una classe, e se lo trova, viene
ritornato.

Sintassi:
	'(' field <istance> <field-name> ')'

<instance>  	   e' un'istanza di una classe;
<field-name>	   e' un simbolo, rappresenta un campo.


- FIELD*

Estrae il valore da una classe percorrendo una catena di attributi, e
se lo trova, viene ritornato.

Sintassi:
	'(' field* <instance> <field-name>+ ')'

<instance>  	   e' un'istanza di una classe;
<field-name>+	   e' una lista non vuota di simboli.


- CLASS-SPEC

Ritorna la struttura di una classe.

Sintassi:
	'(' class-spec <class-name> ')'

<class-name>	   e' il nome di una classe.



3) FUNZIONI DI SUPPORTO

Funzioni utilizzate dalle funzioni principali.
Non intese per l'utilizzo stand alone, in quanto utilizzano parametri
specifici il cui controllo potrebbe essere in altre funzioni, ma,
per quanto sconsigliato, sono comunque invocabili ed utilizzabili
normalmente.
Nota: le funzioni per recuperare i campi e i metodi sono molto simili,
cio' fatto al posto di unirli per evitare che ogni volta che si voglia
cercare un campo, si cerchi anche nei metodi, e viceversa.


- INSERT-PART

Riconosce dove sono i campi e i metodi, e li spedisce in altre
funzioni per effettuare vari controlli.
Chiamata da (def-class).

Sintassi:
	'(' insert-part <parents> <part> ')'

<parents>   	   e' una lista di classi;
<part>		   e' un insieme di campi e/o un insieme di metodi.


- INSERT-FIELDS

Da una lista di campi, manda il primo campo con i genitori della
classe per dei controll, mentre il resto viene inviato ricorsivamento
a se stesso.
Chiamata da (insert-part).

Sintassi:
	'(' insert-fields <parents> <fields> ')'

<parents>   	   e' una lista di classi;
<fields>	   e' una lista di campi.


- CONTROL-FIELD

Fa vari controlli sul campo passato.
Ritorna il campo, con addeguate aggiunte se necessario.
In generale, il campo deve rispettare i vincoli del suo tipo e del
campo genitore, se esiste.
Chiamata da (insert-fields).

Sintassi: '(' control-field <parents> <field> ')'

<parents>     	   e' una lista di classi;
<field>		   e' un campo.


- INSERT-METHODS

Da una lista di metodi, manda ricorsivamente uno ad uno i metodi per
"installarli" in un altra funzione.
Chiamata da (insert-part).

Sintassi:
	'(' insert-methods <methods> ')'

<methods>   	   e' una lista di metodi.


- PROCESS-METHOD

Crea una funzione lambda associata al nome del metodo che recupera il
il codice del metodo, e lo chiama con i parametri necessari.
Chiamata da (insert-methods).

Sintassi:
	'(' process-method <method-name> <method-spec> ')'

<method-name>      e' un simbolo, rappresenta il nome di un metodo;
<method-spec>	   e' una Sexp formato dagli <arglist> e <form> del
		   metodo. 


- REWRITE-METHOD-CODE

Riscrive i parametri del metodo in modo che includano un parametro
this.
Chiamata da (process-method).

Sintassi:
	'(' rewrite-method-code <method-spec> ')'

<method-spec>	   e' una Sexp formato dai <arglist> e <form> di un
		   metodo.


- DUPLICATE-PARTS-CHECK

Controlla che non ci siano campi e metodi ripetuti delle classi ed
istanze durante la creazione.
Chiamata da (insert-part) e (make).

Sintassi:
	'(' duplicate-parts-check <parts-list> <parts-to-check> ')'

<parts-list>	   e' una lista o di campi, o di metodi;
<parts-to-check>   e' una lista o di campi, o di metodi.


- COUNT-PART

Conta quante volte il nome di un campo o metodo viene ripetuto dentro
se stesso.
Chiamata da (duplicate-parts-check).

Sintassi:
	'(' count-part <part-list> part ')'

<part-list> 	   e' una lista o di campi, o di metodi;
<part>		   e' o un campo, o un metodo.


- GROUP-FIELDS

Raggruppa i campi di un'istanza in coppie chiave valore, necessario
per la corretta lettura dalla funzione (duplicate-parts-check), a cui
poi passa la lista completa.
Necessario per il corretto funzionamento di (duplicate-parts-check)
per il controllo delle istanze.
Chiamata da (make).

Sintassi:
	'(' groud-fields <fields> ')'

<fields>    	   e' una lista "piatta" contenenti il nome di un
		   campo ed il suo valore, in sequenza alterna.


- MAKE-FIELDS

Manda la prima coppia chiave valore dai campi di un'istanza ad un
altra funzione per dei controlli, e il resto viene rimandato qui
ricorsivamente.
Chiamata da (make).

Sintassi:
	'(' make-fields <class-name> <fields> ')'

<class-name>	   e' una classe;
<fields>	   e' una lista "piatta" contenenti il nome di un
		   campo ed il suo valore, in sequenza alterna.


- MAKE-FIELD-CHECK

Fa vari controlli sul campo.
In generale, il campo deve esistere nella classe di appartenenza, e
a dipendere dal tipo del campo della classe, deve essere o un'istanza
della classe, o un subtype del suo tipo.

Sintassi:
	'(' make-field-check <class-name> <field> ')'

<class-name>	   e' una classe;
<field>		   e' un campo in forma nome valore.


- IS-CLASS-LIST

Data una lista, controlla se ogni elemento della lista sia una classe.
Chiamata da (def-class).

Sintassi:
	'(' is-class-list <class-list> ')'

<class-list>	   e' una lista di classi;


- IS-CHILD

Controlla se una classe sia sottoclasse dell'altra.
Chiamata da (is-instance) e (control-field).

Sintassi:
	'(' is-child <class-child> <class-parent> ')'

<class-child>	   e' una classe;
<class-parent>	   e' una classe.


- FIELD-INSTANCE

Invia un'istanza e un campo a (field-check) per controllare se
l'istanza  contiene il campo.
Se viene ritornato, ne prende il valore, altrimenti invia un errore.
Chiamata da (field) e (field*).

Sintassi:
	'(' field-instance <instance> <field-name> ')'

<instance>  	   e' un'istanza;
<field-name>	   e' il nome di un campo.


- FIELD-CHECK

Controlla ricorsivamente se un campo e' presente in una lista di
campi, se lo trova, lo rimanda al chiamante.
Se invece, dopo aver controllato tutta la lista, non lo trova, chiama
(field-superclass) per controllare le classi genitori.
Chiamata da (field-instance) e (field-class-location).

Sintassi:
	'(' field-check <field-list> <field-name> <parents> ')'

<field-list>	   e' una lista di campi;
<field-name>	   e' il nome di un campo.


- FIELD-SUPERCLASS

Da una lista di classi, manda a (field-class-location) la prima classe
per cercare un campo, e, se non la trova, prosegue ricorsivamente con
il resto delle classi.
Chiamata da (field-check), (field-class-location), (control-field) e
(make-field-check).

Sintassi:
	'(' field-superclass <classes> <field-name> ')'

<classes>   	   e' una lista di classi;
<field-name>	   e' il nome di un campo.


- FIELD-CLASS-LOCATION

Cerca dove sono i campi nella struttura di una classe, e li invia a
(field-check) per la ricerca del campo.
Se la classe non ha campi, chiama (field-superclass) per controllare
le classi genitori.
Chiamata da (field-superclass).

Sintassi:
	'(' field-class-location <class> <field-name> ')'

<class>	    	   e' una classe;
<field-name>	   e' il nome di un campo.


- GET-METHOD

Invia a (method-class-location) una classe ed un metodo per cercare se
la classe contiene il metodo, se non viene trovato, viene inviato un
errore.
Chiamata dalla funzione lambda creata da (process-method).

Sintassi:
	'(' get-method <class> <method-name> ')'

<class>	    	   e' una classe;
<method-name>	   e' il nome di un metodo.


- METHOD-CHECK

Controlla ricorsivamente se un metodo e' presente in una lista di
metodi, se lo trova, lo rimanda al chiamante.
Se invece, dopo aver controllato tutta la lista, non lo trova, chiama
(method-superclass) per controllare le classi genitori.
Chiamata da (method-class-location).

Sintassi:
	'(' method-check <method-list> <method-name> <parents> ')'

<method-list>	   e' una lista di metodi;
<method-name>	   e' il nome di un metodo.


- METHOD-SUPERCLASS

Da una lista di classi, manda a (method-class-location) la prima
classe per cercare un metodo, e, se non la trova, prosegue
ricorsivamente con il resto delle classi.
Chiamata da (method-check) e (method-class-location).

Sintassi:
	'(' method-superclass <classes> <method-name>

<classes>   	   e' una lista di classi;
<method-name>	   e' il nome di un metodo.


- METHOD-CLASS-LOCATION

Cerca dove sono i metodi nella struttura di una classe, e li invia a
(method-check) per la ricerca del metodo.
Se la classe non ha metodi, chiama (method-superclass) per controllare
le classi genitori.
Chiamata da (get-method) e (method-superclass).

Sintassi:
	'(' method-class-location <class> <method-name>

<class>	    	   e' una classe;
<method-name>	   e' il nome di un metodo.



4) ESEMPI

Creazione di una classe:
chiamata person;
genitori nil;
campi: name di valore "Eve",
       age di valore 21 e tipo integer.

       CL-PROMPT > (def-class 'person nil '(fields (name "Eve")
       		   (age 21 integer)))
       PERSON


Creazione di una classe:
chiamata student;
genitori la classe person;
campi: name "Eva Lu Ator",
       university "Berkeley" di valore string;
metodi: talk
	argomenti: (opzionali) out *standard-output*
	forma: format out

       CL-PROMPT > (def-class 'student '(person)
       		   '(fields
		   (name "Eva Lu Ator")
		   (university "Berkeley" string))
		   '(methods
		   (talk (&optional (out *standard-output*))
		   (format out "My name is ~A~%My age is ~D~%"
		   (field this 'name)
		   (field this 'age)))))
       STUDENT


Creazione di un parametro s1 come istanza:
classe: student;
campi: name "Eduardo De Filippo",
       age 108.

       CL-PROMPT > (defparameter s1 (make 'student
       		   'name "Eduardo De Filippo" 'age 108))
       S1


Recupero dei field di s1:

       CL-PROMPT > (field s1 'age)
       108

       CL-PROMPT > (field s1 'name)
       "Eduardo De Filippo"

       CL-PROMPT > (field s1 'university)
       "Berkeley"


Invocazione del metodo talk di s1:

       CL-PROMPT > (talk s1)
       My name is Eduardo De Filippo
       My age is 108
