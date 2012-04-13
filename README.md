# Snake Assembler

Gra Snake napisana w asemblerze pod procesor 8086. Gra ta wykorzystuje tryb tekstowy 80x25 gdzie rysujemy znaki ASCII po pamiêci.


Instrukcja kompilacji
---------------------

Gra by³a kompilowana TASM i linkowana TLINK.

W zwi¹zku z tym, ¿e gra korzysta z trybu DOSa to nale¿y j¹ odpaliæ pod emulatorem [Dosbox](http://www.dosbox.com/)

Po zainstalowaniu Dosbox tworzymy sobie na dysku katalog: `C:\Assembler`
Wrzucamy do niego kod naszej gry czyli plik `snake.asm` oraz kompilator z linkerem (TASM i TLINK). TASMa i TLINK musimy pobraæ z Internetu.

Uruchamiamy emulator Dosbox. Musimy zamontowaæ katalog z nasz¹ gr¹ wpisuj¹c poni¿sze polecenia.
Ka¿da nowa linia to kolejne polecenie które wpisujemy w oknie Dosbox. Ostatnie polecenie uruchamia naszego snake'a.

	mount C C:\Assembler
	C:
	tasm snake
	tlink snake
	snake

* W tym repozytorium znajduje siê ju¿ skompilowany plik `snake.exe` który mo¿na bezpoœrednio uruchomiæ pod Dosbox.
	
	
Opis mo¿liwoœci gry Snake Assembler
-----------------------------------
	
Gra oferuje ró¿ne tryby szybkoœci poruszania siê wê¿a oraz mo¿liwoœæ losowania dodatkowych owoców na planszy. Standardowo na planszy ca³y czas s¹ dwa czerwone owoce. 
Klawiszem 4 zwiêkszamy o jeden liczbê owoców na planszy. Klawisz 5 dodaje nam piêæ owoców na planszê. Pozycja ka¿dego kolejnego owocu jest losowana przy kolejnym ruchu wê¿a o jedno pole. 
Klawisz 6 ustawia nam liczbê owoców na standardow¹ czyli na dwa. Oznacza to, ¿e dopiero gdy snake zje owoce znajduj¹ce siê na planszy to ponownie bêd¹ losowane kolejne owoce tak aby zawsze na planszy znajdowa³y siê max dwa owoce.

Gra jest szczegó³owo opisana komentarzami tak¿e nie powinno byæ problemów ze zrozumieniem kodu.
Ogólnie mechanika gry opiera siê na tym, ¿e snake zapisywany jest w tablicy bêd¹cej kolejk¹. Ka¿da nowa pozycja g³owy wê¿a jest dopisywana na pocz¹tku kolejki zaœ z jej koñca pobierany jest adres ogona wê¿a w którego miejsce wstawiany jest znak pod³o¿a po którym porusza siê w¹¿.

Gra koñczy siê w momencie gdy dotkniemy ¿ó³tej ramki planszy lub gdy w¹¿ wjedzie na samego siebie. A tak¿e w momencie gdy zawrócimy wê¿a o 180 stopni.