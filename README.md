# Snake Assembler

Gra Snake napisana w asemblerze pod procesor 8086. Gra ta wykorzystuje tryb tekstowy 80x25 gdzie rysujemy znaki ASCII po pami�ci.


Instrukcja kompilacji
---------------------

Gra by�a kompilowana TASM i linkowana TLINK.

W zwi�zku z tym, �e gra korzysta z trybu DOSa to nale�y j� odpali� pod emulatorem [Dosbox](http://www.dosbox.com/)

Po zainstalowaniu Dosbox tworzymy sobie na dysku katalog: `C:\Assembler`
Wrzucamy do niego kod naszej gry czyli plik `snake.asm` oraz kompilator z linkerem (TASM i TLINK). TASMa i TLINK musimy pobra� z Internetu.

Uruchamiamy emulator Dosbox. Musimy zamontowa� katalog z nasz� gr� wpisuj�c poni�sze polecenia.
Ka�da nowa linia to kolejne polecenie kt�re wpisujemy w oknie Dosbox. Ostatnie polecenie uruchamia naszego snake'a.

	mount C C:\Assembler
	C:
	tasm snake
	tlink snake
	snake

* W tym repozytorium znajduje si� ju� skompilowany plik `snake.exe` kt�ry mo�na bezpo�rednio uruchomi� pod Dosbox.
	
	
Opis mo�liwo�ci gry Snake Assembler
-----------------------------------
	
Gra oferuje r�ne tryby szybko�ci poruszania si� w�a oraz mo�liwo�� losowania dodatkowych owoc�w na planszy. Standardowo na planszy ca�y czas s� dwa czerwone owoce. 
Klawiszem 4 zwi�kszamy o jeden liczb� owoc�w na planszy. Klawisz 5 dodaje nam pi�� owoc�w na plansz�. Pozycja ka�dego kolejnego owocu jest losowana przy kolejnym ruchu w�a o jedno pole. 
Klawisz 6 ustawia nam liczb� owoc�w na standardow� czyli na dwa. Oznacza to, �e dopiero gdy snake zje owoce znajduj�ce si� na planszy to ponownie b�d� losowane kolejne owoce tak aby zawsze na planszy znajdowa�y si� max dwa owoce.

Gra jest szczeg�owo opisana komentarzami tak�e nie powinno by� problem�w ze zrozumieniem kodu.
Og�lnie mechanika gry opiera si� na tym, �e snake zapisywany jest w tablicy b�d�cej kolejk�. Ka�da nowa pozycja g�owy w�a jest dopisywana na pocz�tku kolejki za� z jej ko�ca pobierany jest adres ogona w�a w kt�rego miejsce wstawiany jest znak pod�o�a po kt�rym porusza si� w��.

Gra ko�czy si� w momencie gdy dotkniemy ��tej ramki planszy lub gdy w�� wjedzie na samego siebie. A tak�e w momencie gdy zawr�cimy w�a o 180 stopni.