Zheng Lei Maurizio 866251
[NEED INFOS]
Simone
Filo


 _____   _____   _ 
/  _  \ /  _  \ | |
| | | | | | | | | |
| | | | | | | | | |
| |_| | | |_| | | |___
\_____/ \_____/ |_____|

IINTRODUZIONE

OOL �Eun'estensione "object oriented" di Common Lisp con eredit�E
multipla.
Questa estensione permetter�Ea Common Lisp di creare classi e
sottoclassi, aventi dentro campi e metodi, e di creare istanze di
queste classi, con a loro volta i loro campi, ereditati dalla classe.
L'implementazione di ci�E�Esvolto in modo particolare, mostrando solo
i campi e metodi "nuovi" delle classi ed istanze, quindi, a meno che
non si crei un nuovo campo e/o metodo, o non si modifichi una
ereditata, il sistema non mostrer�Etutti i campi e metodi ereditati,
anche se comunque presenti.


FUNZIONI PRINCIPALI

- DEF-CLASS
	
Definisce la struttura di una classe e la memorizza in una locazione
centralizzata (una variabile globale).
Ritorna <class-name>

Sintassi:
	'(' def-class <class-name> <parents> <part>* ')'

	part	    ::= '(' fields <field>* ')'
		    |   '(' methods <method>* ')'
	field	    ::= <field-name>
		    |   '(' <field-name> <value> [<field-type>] ')'
	method	    ::= '(' <method-name> <arglist> <form>* ')'

	field-type  ::= T | <type>


<class-name> 	    �Eun simbolo, definisce il nome della classe;
<parents>	    �Euna lista (possibilmente vuota) di simboli,
		    sono i nomi di altre classi;
<part> 	       	    �Eun insieme di campi, o un insieme di
		    definizionidi metodo. 
<field-name>	    �Eun simbolo;
<value>		    �Eun'espressione costante autovalutante qualunque;
<type>		    �Eil nome di una classe gi�Edefinita con
		    def-class, un tipo numerico Common Lisp, o T;
<method-name>	    �Eun simbolo;
<arglist>	    �Euna lista di parametri standard Common Lisp;
<form>		    �Euna qualunque espressione Common Lisp;


- MAKE

Crea una nuova istanza di una classe.
Ritorna la nuova istanza di <class-name>

Sintassi:
	'(' make <class-name> [<field-name> <value>]* ')'

<class-name>	    �Eun simbolo, rappresenta il nome della classe di
		    appartenenza;
<field-name>	    �Eun simbolo, rappresenta il nome di un campo;
<value>		    �Eun qualunque valore.


- IS-CLASS

Restituisce T se <class-name> �Eil nome di una classe.

Sintassi:
	'(' is-class <class-name> ')'

<class-name>	    �Eun simbolo, rappresenta il nome di una classe.


- IS-INSTANCE

Restituisce T se <value> �El'istanza di una classe.
Se <class-name> �ET, basta che <value> sia un'istanza qualunque;
altrimenti, deve essere un'istanza di una classe avente <class-name>
come superclasse.

Sintassi:
	'(' is-instance <value> [<class-name>] ')'

<class-name>	    �Eun simbolo, rappresenta il nome di una classe;
<value>		    �Eun qualunque valore.


- FIELD

Estrae il valore di un campo da una classe, e se lo trova, viene
ritornato.

Sintassi:
	'(' field <istance> <field-name> ')'

<instance>  	   �Eun'istanza di una classe;
<field-name>	   �Eun simbolo, rappresenta un campo.


- FIELD*

Estrae il valore da una classe percorrendo una catena di attributi, e
se lo trova, viene ritornato.

Sintassi:
	'(' field* <instance> <field-name>+ ')'

<instance>  	   �Eun'istanza di una classe;
<field-name>+	   �Euna lista non vuota di simboli.


- CLASS-SPEC

Ritorna la struttura di una classe.

Sintassi:
	'(' class-spec <class-name> ')'

<class-name>	   �Eil nome di una classe.



FUNZIONI DI SUPPORTO
Funzioni utilizzate dalle funzioni principali.
Non intese per l'utilizzo stand alone, in quanto utilizzano parametri
specifici il cui controllo potrebbe essere in altre funzioni, ma,
per quanto sconsigliato, sono comunque invocabili ed utilizzabili
normalmente.


- INSERT-PART

Riconosce dove sono i campi e i metodi, e li spedisce in altre
funzioni per effettuare vari controlli.
Chiamata da (def-class).

Sintassi:
	'(' insert-part <parents> <part> ')'

<parents>   	   �Euna lista di classi;
<part>		   �Eun insieme di campi e/o un insieme di metodi.


- INSERT-FIELDS

Da una lista di campi, manda il primo campo con i genitori della
classe per dei controll, mentre il resto viene inviato ricorsivamento
a se stesso.
Chiamata da (insert-part).

Sintassi:
	'(' insert-fields <parents> <fields> ')'

<parents>   	   �Euna lista di classi;
<fields>	   �Euna lista di campi.


- CONTROL-FIELD

Fa vari controlli sul campo passato.
Ritorna il campo, con addeguate aggiunte se necessario.
In generale, il campo deve rispettare i vincoli del suo tipo e del
campo genitore, se esiste.
Chiamata da (insert-fields).

Sintassi: '(' control-field <parents> <field> ')'

<parents>     	   �Euna lista di classi;
<field>		   �Eun campo.


- INSERT-METHODS

Da una lista di metodi, manda ricorsivamente uno ad uno i metodi per
"installarli" in un altra funzione.
Chiamata da (insert-part).

Sintassi:
	'(' insert-methods <methods> ')'

<methods>   	   �Euna lista di metodi.


- PROCESS-METHOD

Crea una funzione lambda associata al nome del metodo che recupera il
il codice del metodo, e lo chiama con i parametri necessari.
Chiamata da (insert-methods).

Sintassi:
	'(' process-method <method-name> <method-spec> ')'

<method-name>      �Eun simbolo, rappresenta il nome di un metodo;
<method-spec>	   �Euna Sexp formato dagli <arglist> e <form> del
		   metodo. 


- REWRITE-METHOD-CODE

Riscrive i parametri del metodo in modo che includano un parametro
this.
Chiamata da (process-method).

Sintassi:
	'(' rewrite-method-code <method-spec> ')'

<method-spec>	   �Euna Sexp formato dai <arglist> e <form> di un
		   metodo.


- DUPLICATE-PARTS-CHECK

Controlla che non ci siano campi e metodi ripetuti delle classi ed
istanze durante la creazione.
Chiamata da (insert-part) e (make).

Sintassi:
	'(' duplicate-parts-check <parts-list> <parts-to-check> ')'

<parts-list>	   �Euna lista o di campi, o di metodi;
<parts-to-check>   �Euna lista o di campi, o di metodi.


- COUNT-PART

Conta quante volte il nome di un campo o metodo viene ripetuto dentro
se stesso.
Chiamata da (duplicate-parts-check).

Sintassi:
	'(' count-part <part-list> part ')'

<part-list> 	   �Euna lista o di campi, o di metodi;
<part>		   �Eo un campo, o un metodo.


- GROUP-FIELDS

Raggruppa i campi di un'istanza in coppie chiave valore, necessario
per la corretta lettura dalla funzione (duplicate-parts-check), a cui
poi passa la lista completa.
Chiamata da (make).

Sintassi:
	'(' groud-fields <fields> ')'

<fields>    	   �Euna lista "piatta" contenenti il nome di un campo
		   ed il suo valore, in sequenza alterna.


- MAKE-FIELDS

Manda la prima coppia chiave valore dai campi di un'istanza ad un
altra funzione per dei controlli, e il resto viene rimandato qui
ricorsivamente.
Chiamata da (make).

Sintassi:
	'(' make-fields <class-name> <fields> ')'

<class-name>	   �Euna classe;
<fields>	   �Euna lista "piatta" contenenti il nome di un campo
		   ed il suo valore, in sequenza alterna.


- MAKE-FIELD-CHECK

Fa vari controlli sul campo.
In generale, il campo deve esistere nella classe di appartenenza, e
a dipendere dal tipo del campo della classe, deve essere o un'istanza
della classe, o un subtype del suo tipo.

Sintassi:
	'(' make-field-check <class-name> <field> ')'

<class-name>	   �Euna classe;
<field>		   �Eun campo in forma nome valore.


- IS-CLASS-LIST

Data una lista, controlla se ogni elemento della lista sia una classe.
Chiamata da (def-class).

Sintassi:
	'(' is-class-list <class-list> ')'

<class-list>	   �Euna lista di classi;


- IS-CHILD

Controlla se una classe sia sottoclasse dell'altra.
Chiamata da (is-instance) e (control-field)

Sintassi:
	'(' is-child <class-child> <class-parent> ')'

<class-child>	   �Euna classe;
<class-parent>	   �Euna classe.


- FIELD-INSTANCE

Invia un'istanza e un campo a (field-check) per controllare se
l'istanza  contiene il campo.
Se viene ritornato, ne prende il valore, altrimenti invia un errore.
Chiamata da (field) e (field*).

Sintassi:
	'(' field-instance <instance> <field-name> ')'

<instance>  	   �Eun'istanza;
<field-name>	   �Eil nome di un campo.


- FIELD-CHECK

Controlla ricorsivamente se un campo �Epresente in una lista di campi,
se lo trova, lo rimanda al chiamante.
Se invece, dopo aver controllato tutta la lista, non lo trova, chiama
(field-superclass) per controllare le classi genitori.
Chiamata da (field-instance) e (field-class-location).

Sintassi:
	'(' field-check <field-list> <field-name> <parents> ')'

<field-list>	   �Euna lista di campi;
<field-name>	   �Eil nome di un campo.


- FIELD-SUPERCLASS
  
Da una lista di classi, manda a (field-class-location) la prima classe
per cercare un campo, e, se non la trova, prosegue ricorsivamente con
il resto delle classi.
Chiamata da (field-check), (field-class-location), (control-field) e
(make-field-check).

Sintassi:
	'(' field-superclass <classes> <field-name> ')'

<classes>   	   �Euna lista di classi;
<field-name>	   �Eil nome di un campo.


- FIELD-CLASS-LOCATION

Cerca dove sono i campi nella struttura di una classe, e li invia a
(field-check) per la ricerca del campo.
Se la classe non ha campi, chiama (field-superclass) per controllare
le classi genitori.
Chiamata da (field-superclass).

Sintassi:
	'(' field-class-location <class> <field-name> ')'

<class>	    	   �Euna classe;
<field-name>	   �Eil nome di un campo.


- GET-METHOD

Invia a (method-class-location) una classe ed un metodo per cercare se
la classe contiene il metodo, se non viene trovato, viene inviato un
errore.
Chiamata dalla funzione lambda creata da (process-method).

Sintassi:
	'(' get-method <class> <method-name> ')'

<class>	    	   �Euna classe;
<method-name>	   �Eil nome di un metodo.


- METHOD-CHECK

Controlla ricorsivamente se un metodo �Epresente in una lista di
metodi, se lo trova, lo rimanda al chiamante.
Se invece, dopo aver controllato tutta la lista, non lo trova, chiama
(method-superclass) per controllare le classi genitori.
Chiamata da (method-class-location).

Sintassi:
	'(' method-check <method-list> <method-name> <parents> ')'

<method-list>	   �Euna lista di metodi;
<method-name>	   �Eil nome di un metodo.


- METHOD-SUPERCLASS

Da una lista di classi, manda a (method-class-location) la prima
classe per cercare un metodo, e, se non la trova, prosegue
ricorsivamente con il resto delle classi.
Chiamata da (method-check) e (method-class-location).

Sintassi:
	'(' method-superclass <classes> <method-name>

<classes>   	   �Euna lista di classi;
<method-name>	   �Eil nome di un metodo.


- METHOD-CLASS-LOCATION

Cerca dove sono i metodi nella struttura di una classe, e li invia a
(method-check) per la ricerca del metodo.
Se la classe non ha metodi, chiama (method-superclass) per controllare
le classi genitori.
Chiamata da (get-method) e (method-superclass).

Sintassi:
	'(' method-class-location <class> <method-name>

<class>	    	   �Euna classe;
<method-name>	   �Eil nome di un metodo.
