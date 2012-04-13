;###################################################################################################################
;#	Artur Trzop
;#	Snake 2011
;#	The MIT License
;###################################################################################################################
;#	Notacja w kodzie:
;#
;#		pNR__NazwaProcedury
;#			* p - Ka�da nazwa procedury zaczyna si� od litery p
;#			* NR - oznacza numer procedury
;#			* __ - wymagane dwa podkre�lenia w nazwie procedury
;#			* NazwaProcedury - nazwa naszej procedury
;#
;# 		pNR1_petla_NR2
;#			* pNR1 - numer procedury w kt�rej wyst�puje p�tla
;#			* petla - sta�e oznaczenie, �e to p�tla
;#			* NR2 - numer p�tli wyst�puj�cej w procedurze pNR1
;#
;#		petla_Nazwa [S� to oznaczenia dla p�tli umieszczonych globalnie]
;#			* petla_ - oznaczenie ze to p�tla
;#			* Nazwa - nazwa dla p�tli
;#
;#		e_pNR1_NR2
;#			* e_ - oznacza, �e to etykieta
;#			* pNR1 - numer p�tli w kt�rej wyst�puje etykieta
;#			* NR2 - numer etykiety wyst�puj�cej w p�tli pNR1
;#		
;#		e_Nazwa [S� to oznaczenie dla etykiet globalnych]
;#			* e_ - oznaczenie, �e to etykieta
;#			* Nazwa - nazwa naszej etykiety
;#
;#		z_Nazwa
;#			* z_ - prefix oznaczaj�cy zmienn�
;#			* Nazwa - nazwa naszej zmiennej
;#
;###################################################################################################################

; Stos
stos1 segment STACK
	dw 1024 dup(?) ; podw�jne s�owo, dup-duplikat ?-brak okre�lonej warto�ci, pojemno�� 1024
	szczyt label word
stos1 ends

dane segment PUBLIC ; PUBLIC - segmenty o tej samej nazwie ��czone s� w jeden ci�g�y segment. Wszystkie adresy w segmencie s� ��czone wzgl�dem jego pocz�tku.
			
	;=== Zmienne	
	; 0Dh, 0Ah - znaki nowej linii \r\n
	z_txt_intro db "Artur Trzop 12K2 | 2011 Gra Snake", 0Dh, 0Ah, 0Dh, 0Ah
				db "ESC - wyjscie", 0Dh, 0Ah
				db "Strzalki - start gry, ruch wezem w dana strone", 0Dh, 0Ah, 0Dh, 0Ah				
				db " _______    _          _______    _          _______ ", 0Dh, 0Ah
				db "(  ____ \  ( (    /|  (  ___  )  | \    /\  (  ____ \", 0Dh, 0Ah
				db "| (    \/  |  \  ( |  | (   ) |  |  \  / /  | (    \/", 0Dh, 0Ah
				db "| (_____   |   \ | |  | (___) |  |  (_/ /   | (__    ", 0Dh, 0Ah
				db "(_____  )  | (\ \) |  |  ___  |  |   _ (    |  __)   ", 0Dh, 0Ah
				db "      ) |  | | \   |  | (   ) |  |  ( \ \   | (      ", 0Dh, 0Ah
				db "/\____) |  | )  \  |  | )   ( |  |  /  \ \  | (____/\", 0Dh, 0Ah
				db "\_______)  |/    )_)  |/     \|  |_/    \/  (_______/", 0Dh, 0Ah, 0Dh, 0Ah
				db "1 - mala predkosc weza", 0Dh, 0Ah
				db "2 - srednia predkosc weza", 0Dh, 0Ah
				db "3 - duza predkosc weza", 0Dh, 0Ah
				db "4 - zwieksz limit owocow o jeden", 0Dh, 0Ah
				db "5 - zwieksz limit owocow o 5", 0Dh, 0Ah
				db "6 - ustaw limit owocow na 2", 0Dh, 0Ah, 0Dh, 0Ah
				db "Aby rozpoczac nacisnij dowolny klawisz...$"
		
	; D�ugo�c w�a. Typ dw czyli s�owo (16 bajt�w poniewa� mo�e w�� urosn�� do maksymalnie 1794 (ca�a plansza zarysowana. Hipotetyczna sytuacja)) 
	z_dlugosc_weza dw 1  ; Domy�lnie jeden poniewa� na pocz�tku tak� d�ugo�� ma w��
	z_odczekaj dw 0 ; Zmienna przechowujaca czas odczekania
	z_kierunek db 0 ; Kierunek ruchu w�a
	; Kody strza�ek: 75-lewo 77-prawo 72-gora 80-dol
	z_lewo db 75d
	z_prawo db 77d
	z_gora db 72d
	z_dol db 80d
	z_esc db 27d
	z_wynik db 0Dh, 0Ah, "KONIEC", 0Dh, 0Ah, "Zdobyles punktow: $"
	z_szybkosc db 4 ; okre�la szybko�� w�a. Im mniejsza tym szybciej si� w�� porusza
	z_owocow_na_planszy dw 0 ; informuje ile jest owocow na planszy. Gdy b�d� 2 to nie b�dziemy dalej losowa� kolejnych
	z_losowa1 dw 0 ; losowa liczba
	z_losowa2 dw 0
	z_limit_owocow dw 2 ; Ustalamy ile owocow moze byc na planszy jednoczesnie
	
	;=== Sta�e
	s_kolor_ramki equ 14d ; ��ty kolor dla ramki planszy
	s_kolor_podloza equ 10d ; zielony jasny
	s_kolor_weza equ 15d ; bia�y
	s_kolor_owoc equ 12d ; czerwony	
	s_ascii_podloze equ 176d ; kod ASCII pod�o�a (trawa)
	s_ascii_waz equ 219d ; kod ASCII kratka zamalowana
	
	
	;=== tablice
	; Tablica b�dzie przechowywa�a po�o�enie ka�dego z klock�w b�d�cych cz�ci� w�a. 
	; (80-2)*(25-2)=1796 Maksymalne zarysowanie planszy przez w�a. Pomijamy ramki czyli odejmujemy dwa
	; Tablice wype�niamy zerami.
	; Pierwszy element tablicy to g�owa w�a, ka�dy kolejny to 
	s_tab_limit equ 1794d ; Sta�y limit wielkosci tablicy
	tab_waz dw s_tab_limit dup(0) 
	; UWAGA: Opis dzia�ania
	; Tablica b�dzie dzia�a� jak kolejka. Podczas ruchu w�a w miejsce indexu 0 wstawiany b�dzie numer po�o�enia g�owy w�a na ekranie.
	; Dlasze cz�ci w�a b�d� po prostu przesuni�te w tablicy o jeden element w g�r�. Ostatni element b�dzie kasowany przy ka�dym kolejnym ruchu.
	; Napro�ciej m�wi�c przy ka�dym kolejnym ruchu w�a elementy jego po�o�enia b�d� si� przesuwa� o jeden index w g�r�.
	; Na index 0 w tablicy wchodzi element do kolejki, a z ostatniego indexu wychodzi element z kolejki.
	; W przypadku gdy w�� zje owoc to nie b�dzie kasowany ostatni element tablicy dzi�ki czemu w�� uro�nie o jeden element.
	; Do kontrolowania d�ugo�ci w�a wykorzystamy zmienn� pomocnicz� z_dlugosc_weza
	; UWAGA##### Tablica typu dw dlatego drugi element jest pod indexem 2. B�dziemy skaka� co dwa indexy!!
	
dane ends

; AT - segmenty z tym po��czeniem s� �adowane 
; od adresu wskazanego przez wyra�enie numeryczne
; w naszym przypadku pod adresem 0B8000h znajduje 
; si� pocz�tek pami�ci ekranu
ekran segment AT 0B800h 
	ek db ?
	atr db ?
ekran ends


; Segment kodu
code segment ; PRIVATE
	
	assume cs:code,ds:dane,es:ekran,ss:stos1
	
	start:
		mov	ax,seg dane ;�adujemy rejestry segmentowe DS i ES
		mov	ds,ax
		mov ax,seg ekran ;pami�� ekranu do ES
		mov	es,ax
		;mov	ax,seg code
		mov ax,stos1
		mov ss,ax
		mov sp,offset szczyt
		
		MOV	AH,0 ;wyb�r trybu pracy monitora
		MOV	AL,3 ;text 80x25 kolor
		INT	10H	;obs�uga ekranu	
		
		
		; Ukrywamy migotaj�cy kursor
		mov ah, 1
		mov ch, 2bh
		mov cl, 0bh
		int 10h
		
		
		mov	dx,offset z_txt_intro
		mov	ah,9h ; wypisanie tekstu intro	
		int	21h	
		
		call p2__KolorujIntro ; wywo�anie procedury koloruj�cej napis SNAKE w intro
				
		; Czeka na naci�ni�cie dowolnego klawisza
		mov ah, 00h
		int 16h
		
				
		; Rysujemy plansze
		call p1__RysujPlansze
		
		
		
		; Rysujemy w�a w pocz�tkowym miejscu
		mov	ek[2000],219d ; Znak ASCII blok zamalowany 
		mov atr[2000],s_kolor_weza
		
		
		call p4__LosujOwoc
		
		
		
		
		
		;### Naci�ni�cie ESC spowoduje wyj�cie z gry
		;### Nacisni�cie strza�ek powoduje start gry
		;### Je�li naci�niemy inny klawisz to gra czeka a� naci�niemy kt�ry� z wy�ej wymienionych
		e_UruchomGre:
			mov ah,08h ; Pobiera znak z klawiatury. B�dzie zapisany w AL
			int 21h ; przerwanie
			
			cmp al,z_esc ; je�li znak to ESC to wychodzimy z programu
			; Tutaj musilismy wykona� trik z stworzeniem pomostu w skoku. Poniewa� skok "je" i inne mu podobne s� kr�tkimi skokami
			; Powodowa�o to �e nie mo�na by�o z tego miejsca skoczy� do ko�ca programu (relative jump out of range)
			; Dlatego wykonano pomost i u�yto skoki jmp
			je e_pomost_jmp 
				jmp e_pomin_pomost
			e_pomost_jmp:
			jmp e_KoniecProgramu
			e_pomin_pomost:
			
			; Kody strza�ek: 75-lewo 77-prawo 72-gora 80-dol
			cmp al,z_lewo ; strz�ka w lewo	
			je e_StartWeza
			cmp al,z_prawo ; strz�ka w prawo	
			je e_StartWeza
			cmp al,z_gora ; strz�ka w g�r�	
			je e_StartWeza
			cmp al,z_dol ; strz�ka w d�	
			je e_StartWeza
						
			; Je�li doszli�my do tego kroku to znaczy �e nie przechwycono klawisza ESC ani strza�ek zatem ponownie oczekujemy na naci�ni�cie klawisza
			jmp e_UruchomGre 
		
		
		
		;### W�� zaczyna ruch. Ten blok wykona si� tylko przy rozpocz�ciu gry
		e_StartWeza:		
			; Je�li wskoczylismy tu z g�ry gdzie mamy wyb�r kierunku ruchu w�a przy rozpocz�ciu gry to znaczy �e w AL mamy warto�� strza�ki okre�laj�cej 
			; w kt�r� stron� zaczyna ruch w��. Zatem �adujemy do z_kierunek warto�� wybranej strza�ki
			mov z_kierunek,al 
			; Do pierwszego elementu tablicy �adujemy po�o�enie pocz�tkowe naszego w�a			
			mov tab_waz[0],2000d ; Jest to po�o�enie g�owy. G�owa zawsze jest pod indexem 0 w tablicy
						
		
		e_RuchWeza: ; etykieta do kt�rej skaczemy gdy w�� jest ju� w ruchu
			
			mov di,tab_waz[0] ; di zawiera numer pozycji w ktorej narysowana jest g�owa w�a
										
			mov al,z_kierunek ; �adujemy z_kierunek do AL �eby m�c wykonac por�wnanie.
				
			cmp al,z_lewo
			jne e_pomin1 ; Je�li nie wci�ni�to lewo to skaczemy do nast�pnego por�wnania
				; Ten blok si� wykona je�li wci�nieto lewo
				sub di,2 ; 
			e_pomin1:
			
			cmp al,z_prawo
			jne e_pomin2
				add di,2
			e_pomin2:
			
			cmp al,z_gora
			jne e_pomin3
				sub di,160 ; odejmujemy 160 aby przesun�c si� o jeden wiersz w g�r�
			e_pomin3:
			
			cmp al,z_dol
			jne e_pomin4
				add di,160 ; dodajemy 160 aby przesun�c si� o jeden wiersz w d�
			e_pomin4:
			
			
			push di
			push ax
			push cx
			
			; wywo�ujemy procedure kt�ra sprawdzi czy w�� wjecha� na niedozwolony element ramke planszy
			; lub je�li wjecha� na owoc to powoduje to wydluzenie w�a
			call p3__SprawdzZdarzenie
			
			; wywo�ujemy procedure losujaca owoc
			call p4__LosujOwoc
			
			pop cx
			pop ax
			pop di
			
			
		
		e_PobierzKlawisz:
			mov ah,01h ; Sprawdzamy czy naci�ni�to klawisz
			int 16h
			jz e_NieWybranoKlawisza ; Skok je�li liczba r�wna zero, czyli je�li nie naci�ni�to �adnego klawisza

			mov ah,00h
			int 16h

			cmp al,z_esc ; Por�wnujemy do klawisza ESC 
			je e_KoniecProgramu ; Je�li naci�ni�to ESC to skaczemy do wyj�cia z gry 
			
			; Je�li naci�ni�to klawisze 1,2,3 to zmieniamy szybko�� w�a
			cmp al,31h
			je e_szyb_1				
			cmp al,32h
			je e_szyb_2			
			cmp al,33h
			je e_szyb_3
			
			; Je�li naci�ni�to 4 to zwiekszamy limit owocow na planszy o jeden
			; je�li 5 to zwiekszamy limit o 5
			; je�li naci�ni�to 6 to resetujemy limit owocow na 2
			cmp al,34h ;4 - zwiekszamy limit owocow o 1
			je e_limit_owocow1				
			cmp al,35h ;5 - zwiekszamy limit owocow o 5
			je e_limit_owocow2	
			cmp al,36h ;6 - resetujemy limit owocow na 2
			je e_limit_owocow3
			
			
			mov z_kierunek,ah ; �adujemy numer naci�ni�tego klawisza do zmiennej informuj�cej o kierunku ruchu
			jmp e_NieWybranoKlawisza ; skaczemy do etykiety aby pominac ustawienia szybkosci jesli nie skoczono do nich wczesniej
			
			
			; Obs�uga zmiany szybkosci ruchu w�a
			e_szyb_1:
				mov z_szybkosc,4 ; wolno
				jmp e_NieWybranoKlawisza
			e_szyb_2:
				mov z_szybkosc,2 ; �rednia pr�dko��
				jmp e_NieWybranoKlawisza
			e_szyb_3:
				mov z_szybkosc,1 ; szybko
				jmp e_NieWybranoKlawisza
				
				
			; Obs�uga zmiany limitu owocow na planszy
			e_limit_owocow1:
				add z_limit_owocow,1 ; dodajemy jeden
				jmp e_NieWybranoKlawisza
			e_limit_owocow2:
				add z_limit_owocow,5
				jmp e_NieWybranoKlawisza
			e_limit_owocow3:
				mov z_limit_owocow,2
				jmp e_NieWybranoKlawisza	
				
			
		e_NieWybranoKlawisza:



		; Op�nienie. Cykl 18,2 na sekund�
		mov ah,00h
		int 1ah
		cmp dx,z_odczekaj
		jb e_PobierzKlawisz ; jb - skok gdy jest poni�ej (CF=1)
		xor cx,cx
		mov cl,z_szybkosc ; Dzi�ki tej zmiennej b�dziemy mogli zmienia� sobie szybko�� w�a
		add dx,cx
		mov z_odczekaj,dx
		
		
		jmp e_RuchWeza ; Powtarzamy ruch w�a skacz�c do etykiety e_RuchWeza
		
		
		
	
		
		
		;mov	dx,offset tekst1
		;mov	ah,9h ; wypisanie tekstu (DOS)		
		;int	21h	; funkcja DOS
			
		;int 16h ; Wymaga naci�ni�cia dowolnego klawisza aby przej�� dalej
		
		e_KoniecProgramu:	
			mov	ax,4c00h;koniec programu (DOS)
			int	21h
	





	;###################################################################################################################
	;### Procedury
	;### ASCII http://www.asciitable.com/

	;=== Rysowanie obramowania planszy =================================================================================
	p1__RysujPlansze proc
		
		;=== Ustawiamy limit ekranu, limit ile razy si� p�tla wykona
		mov	cx,80*25
		
		
		;=== Rysujemy t�o planszy kt�re b�dzie pod�o�em (trawa). T�o to b�dzie p�niej zamalowane przez ramki planszy
		mov	si,0
		p1_petla_1:	
			mov	ek[si],s_ascii_podloze ; kod ASCII dla kropeczek, kt�re b�d� udawac traw�
			mov atr[si],s_kolor_podloza ; zielony jasny
			add si,2 ; zwi�kszamy index o dwa
		loop p1_petla_1
		
		
		
		;=== Rysujemy g�rn� i doln� linie obramowania planszy				
		mov	si,0 ; zaczynamy rysowanie od indexu zero
		p1_petla_2:

			; rysowanie g�rnej poziomej linii
			cmp si,160d
			jge e_p1_1 ; je�li rysujemy ju� powy�ej 80 znaku to pomijamy rysowanie (je�li si jest wi�ksze lub r�wne 160 (dlatego r�wne bo rysujemy od 0))
				mov	ek[si],219d ; Znak ASCII blok zamalowany 				
				mov atr[si], s_kolor_ramki ; �adujemy ��ty kolor
			e_p1_1:
			
			; rysowanie poziomej linii na dole ekranu
			cmp si,3840d ; 2*80*25 = 2*2000 = 4000  (od 4000 odj�c jedn� linijk� tekstu 80*2 czyli 4000-160=3840)
			jnge e_p1_2 ; skok gdy nie jest wi�kszy od
				mov	ek[si],219d ; Znak ASCII blok zamalowany 
				mov atr[si],s_kolor_ramki ; �adujemy ��ty kolor
			e_p1_2:
						
			add si,2 ; zwi�kszamy index o dwa poniwa� 1-to znak ASCII a 2-to atrybut
		loop p1_petla_2
		
		
		
		;=== Rysujemy linie ponow� z lewej strony
		; 23 poniewa� b�dziemy rysowa� pionow� linie z pomini�ciem ju� narysowanego jednego znaku u g�ry i do�u ekranu
		mov	cx,23 ; limit wywo�ania p�tli.
		mov si,160
		p1_petla_3:
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_ramki ; �adujemy ��ty kolor			
			add si,160 ; przesuwamy si� o jeden ca�y wiersz
		loop p1_petla_3
		
		
		
		;=== Rysujemy linie ponow� z prawej strony
		; 23 poniewa� b�dziemy rysowa� pionow� linie z pomini�ciem ju� narysowanego jednego znaku u g�ry i do�u ekranu
		mov	cx,23 ; limit wywo�ania p�tli.
		mov si,318 ; zaczynamy rysowanie od 318 czyli od drugiego wiersza i ostatniego znaku w nim. (160 + 158)
		p1_petla_4:
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_ramki ; �adujemy ��ty kolor			
			add si,160 ; przesuwamy si� o jeden ca�y wiersz
		loop p1_petla_4
		
		

		ret ; Powr�t 
	p1__RysujPlansze endp





	;=== Rysowanie obramowania planszy =================================================================================
	p2__KolorujIntro proc

		mov	cx,80*8 ; limit wywo�ania p�tli. Ustawiamy na 8 bo chcemy ustawic kolor dla osmiu wierszy (ka�dy wiersz to 80 znak�w czyli 160 bo mamy atrybut)
		mov si,5*160 ; zaczynamy rysowanie od 5 wiersza bo tam zaczyna si� napis SNAKE
		mov al,1d ; �adujemy kolor do AL
		p2_petla_1:
			
			; Kolor wiersza 0 jest ustawiony powy�ej w AL. Pierwsza linia znak�w kt�ra rysuje duzy napis SNAKE
			
			cmp si,6*160
			je e_p2_kolor_wiersza_1 ; je�li si r�wne 6*160 to mo�emy zmieni� kolor przechowywany w al
			cmp si,7*160
			je e_p2_kolor_wiersza_2
			cmp si,8*160
			je e_p2_kolor_wiersza_3
			cmp si,9*160
			je e_p2_kolor_wiersza_4
			cmp si,10*160
			je e_p2_kolor_wiersza_5
			cmp si,11*160
			je e_p2_kolor_wiersza_6
			cmp si,12*160
			je e_p2_kolor_wiersza_7
			cmp si,13*160
			je e_p2_kolor_wiersza_8
			
		
			; Przeskakujemy ustawienia kolor�w. Je�li powy�ej nie nast�pi� skok do zmiany koloru w rejestrze AL to pomijamy zmiane kolor�w 
			; skacz�c do e_p2_1 i u�ywaj�c koloru aktualnie przechowywanego w rejestrze AL.
			; Dzi�ki takiemu zabiegowi nie b�dziemy ustawia� rejestru AL na ten sam kolor przy ka�dym ponowym ustawianiu atrybutu danego znaku na ekranie
			jmp e_p2_1 
		
		
			; Po ustawieniu danego koloru w AL przeskakujemy do jego ustawienia na ekranie
			e_p2_kolor_wiersza_1:
				mov al,2d
				jmp e_p2_1 
			e_p2_kolor_wiersza_2:
				mov al,3d
				jmp e_p2_1
			e_p2_kolor_wiersza_3:
				mov al,4d
				jmp e_p2_1
			e_p2_kolor_wiersza_4:
				mov al,5d
				jmp e_p2_1
			e_p2_kolor_wiersza_5:
				mov al,6d
				jmp e_p2_1
			e_p2_kolor_wiersza_6:
				mov al,7d
				jmp e_p2_1
			e_p2_kolor_wiersza_7:
				mov al,8d
				jmp e_p2_1
			e_p2_kolor_wiersza_8:
				mov al,9d
				jmp e_p2_1
		
			
			e_p2_1:		
				mov atr[si],al ; �adujemy ��ty kolor			
				add si,2 ; przesuwamy si� o dwa czyli o jedn� literk�
			
		loop p2_petla_1
		
		ret ; Powr�t
	p2__KolorujIntro endp
	
	
	
	
	
	
	;=== Funkcja sprawdzaj�ca czy dotkni�to �ciany lub owocu =======================================================================
	; Je�li dotkni�to owocu to nast�puje wyd�u�enie w�a.
	; Funkcja ponadto obs�uguje ruch w�a i zapis jego po�o�enia w kolejce opartej o tablic� tab_waz
	p3__SprawdzZdarzenie proc

		; W di zapisany jest numer w kt�rym postawiona b�dzie g�owa w�a. Sprawdzimy czy uderzy o �cian�
		
		cmp atr[di],s_kolor_ramki
		jne p3_pomin1 ; je�li kolor klocka na kt�ry wstawi� chcemy w�a nie jest koloru ramki to przeskakujemy
			jmp p3_uderzono_w_przeszkode ; jesli wjechalismy na	ramke
		p3_pomin1:
		cmp atr[di],s_kolor_weza 
		jne p3_pomin2 ; je�li kolor klocka na kt�ry wstawi� chcemy w�a nie jest koloru w�a to przeskakujemy
			jmp p3_uderzono_w_przeszkode
		
		
		p3_uderzono_w_przeszkode:
			mov	dx,offset z_wynik
			mov	ah,9h ; wypisanie tekstu o ko�cu gry.	
			int	21h	
			
			xor ax,ax
			mov ax,z_dlugosc_weza ; �adujemy do ax dlugosc weza
			push ax ; wk�adamy na stos ax
			call p5__DrukujLiczbe ; wywo�ujemy procedure wypisujaca wynik liczbowy
			
			
			; Czeka na naci�ni�cie dowolnego klawisza
			mov ah, 00h
			int 16h
			
			jmp e_KoniecProgramu
			
			
		p3_pomin2:
		
		; Tutaj napisac sprawdzanie najechania na owoc. Ma to spowodowac ze nie wywola sie kasowanie ogona
		xor bx,bx
		; w bl b�dziemy przechowywac informacje czy nast�pi�o zjedzenie owoca. 
		; Je�li tak to inna b�dzie wywo�ywana p�tla.
		; 0-oznacza ze nie zwiekszono dlugosci weza		
		mov bl,0 
		
		cmp atr[di],s_kolor_owoc
		jne p3_pomin3 ; je�li nie stawiamy g�owy w�a na owocu to skaczemy do etykiety
			; Ten blok wykona si� gdy postawili�my g�ow� w�a na owocu
			; Dodajemy zwi�kszamy wi�c d�ugo�� w�a
			add z_dlugosc_weza,1
			mov bl,1 ; ustawiamy flag� z informacj� �e zwi�kszono d�ugo�� w�a bo zjedzono owoc			
			
		p3_pomin3:
			
			
			;############
			; Gdy w�� d�u�szy ni� 1 i nie zwi�kszono jego d�ugo�ci
			cmp z_dlugosc_weza,1
			jle e_pomin_war1_; skok gdy jest mniejszy lub rowny 1
				jmp e_pomin_war1_blok
			e_pomin_war1_: ; pomost aby wykonac dlugi skok
				jmp e_pomin_war1
				e_pomin_war1_blok:
				; Ten blok si� wykona gdy w�� ma d�ugo�� wi�ksz� od 1
				cmp bl,0
				jne e_pomin_war2 ; skocz gdy bl nie jest rowne 0
					;###### Ten blok wykona si� gdy bl=0 czyli gdy nie zjedzono owocu
					; Przenosimy elementy w tablicy o jeden index w g�r�, a w miejsce indexu=0 wstawimy now� g�ow� w�a
					xor cx,cx ; czy�cimy cx
					; ile razy ma si� wykona� p�tla. Jest to ilo�� operacji przeniesienia element�w w tablicy kt�ra jest nasz� kolejk�
					; Dlatego -1 bo nie przenosimy ostatniego elementu nigdzie dalej gdyz ma byc on nadpisany przez przedostatni element
					mov cx,z_dlugosc_weza
					sub cx,1
					
					; si b�dziemy zmniejsza� co krok
					; -4 poniewaz ostatni element tablicy nie bedzie przenoszony poniewaz jest on kasowany jesli nie najechano na owoc. A minus 4 poniewa� tablica zaczyna si� od indexu 0 i skaczemy co dwa indexy aby dostac sie do kolejnego elementu
					mov si,z_dlugosc_weza
					add si,z_dlugosc_weza ; dwukrotna dlugosc zapisujemy poniewaz idziemy po tablicy co 2 indexy
					sub si,4

					; Kasowanie ostatniego elementu z planszy
					; odbywa si� przed operacj� przeniesienia element�w w tablicy o jeden index w g�r�
					; poniewa� w czasie przeniesienia tych elementow przedostatni element przykrywa ostatni i nie mielibysmy pozniej mozliwosci odczytania jakie polozenie ma ogon weza
					push di
					xor di,di
					mov di,tab_waz[si+2] ; +2 poniewaz wyzej mielismy -4 i to bylo wybranie przedostatniego elementu a my potrzebujemy ostatni element w tablicy
					mov	ek[di],s_ascii_podloze ; Znak ASCII pod�o�a planszy
					mov atr[di],s_kolor_podloza															
					pop di
					
					p3_petla_1:						
												
						xor ax,ax
						mov ax,tab_waz[si] ; przedostatni element
						mov tab_waz[si+2],ax ; ostatni element przyjmuje wartosc poprzedniego
										
						sub si,2
					loop p3_petla_1
					
					
					
					
					jmp e_pomin_a ; po zakonczonej operacji skaczemy aby pominac bloki ponizsze
				e_pomin_war2:
			
			
				cmp bl,1
				jne e_pomin_a ; skocz gdy bl nie jest rowne 1
					;###### Ten blok wykona si� gdy bl=1 czyli gdy zjedzono owoc
					
					sub z_owocow_na_planszy,1 ; zjedlismy owoc wiec odejmujemy z licznika
					
					; Przenosimy elementy w tablicy o jeden index w g�r�, a w miejsce indexu=0 wstawimy now� g�ow� w�a
					xor cx,cx ; czy�cimy cx
					; ile razy ma si� wykona� p�tla. Jest to ilo�� operacji przeniesienia element�w w tablicy kt�ra jest nasz� kolejk�
					; Dlatego -1 bo nie przenosimy ostatniego elementu nigdzie dalej gdyz ma byc on nadpisany przez przedostatni element
					mov cx,z_dlugosc_weza
					sub cx,1
					
					; si b�dziemy zmniejsza� co krok
					; -4 poniewaz ostatni element tablicy nie bedzie przenoszony poniewaz jest on kasowany jesli nie najechano na owoc. A minus 4 poniewa� tablica zaczyna si� od indexu 0
					mov si,z_dlugosc_weza
					add si,z_dlugosc_weza ; dwukrotna dlugosc zapisujemy poniewaz idziemy po tablicy co 2 indexy
					sub si,4 
					
					p3_petla_2:	
												
						xor ax,ax
						mov ax,tab_waz[si] ; przedostatni element
						mov tab_waz[si+2],ax ; ostatni element przyjmuje wartosc poprzedniego
						
						sub si,2
					loop p3_petla_2
					
					jmp e_pomin_a
			
			e_pomin_war1:
			
			
			
			;###############
			; Poni�szy kod wykonuje si� gdy w�� ma d�ugo�� 1
			cmp z_dlugosc_weza,1
			jne e_pomin_a ; je�li nie jest rowne 1
				; Ten blok wykona si� gdy w�� ma d�ugo�� 1
				push di ; odkladamy di na stos
				mov di,tab_waz[0] ; pobieramy numer pozycji starego polozenia glowy weza
				; wstawiamy podloze w miejsce starego polozenia glowy
				mov	ek[di],s_ascii_podloze ; Znak ASCII pod�o�a planszy
				mov atr[di],s_kolor_podloza
				pop di ; zdejmujemy ze stosu di, ktory nam wskazuje nowe polozenie g�owy w�a
				mov tab_waz[0],di ; zapisujemy glowe weza w tablicy
				jmp e_pomin_b			
			
			e_pomin_a:
				; do pierwszego elementu tablicy �adujemy nowe po�o�enie glowy weza
				mov tab_waz[0],di
				
			e_pomin_b:
			
			; Rysujemy g�owe w�a
			mov	ek[di],s_ascii_waz ; Znak ASCII
			mov atr[di],s_kolor_weza
		
	
		ret
	p3__SprawdzZdarzenie endp
	
	
	
	
	
	
	
	
	;=== Funkcja losuj�ca po�o�enie owoca na planszy =======================================================================
	; Je�li wylosowane pole jest ju� zaj�te to ponawiamy losowanie az trafimy 
	; na puste pole czyli na podloze na ktorym bedziemy mogli postawic owoc
	p4__LosujOwoc proc
		
		mov si,z_limit_owocow
		cmp z_owocow_na_planszy,si
		jge p4_pomin ; je�li na planszy jest wiecej owocow lub tyle samo ile wynosi limit to pomijamy generowanie kolejnych owocow
		
		p4_start: ; rozpoczynamy losowanie owoca
			
			mov ah,2ch 
			int 21h ; Pobieramy czas
			; CH=godziny CL=minuty DH=sekundy DL=1/100s
			
			xor ax,ax
			mov al,dl
			; UWAGA tutaj losujemy tylko do 80 poniewaz dl moze max przyjac wartosc 100.
			; Pozniej sobie zwiekszymy dwukrotnie ta wartosc
			cmp dl,80
			jle p4_pomin2; je�li jest mniejsze lub rowne
				; Ten blok wykona sie gdy dl ma wartosc wieksza od 80
				; Odejmiemy wtedy 20 aby miec dlugosc jednego wiersza
				sub al,20
			p4_pomin2:
			mov z_losowa1,ax ; w zmiennej zapisalismy liczbe z zakresu od 0 do 80
			add ax,z_losowa1 ; teraz ax bedzie dwukrotnoscia losowej liczby wynoszacej max 80
			mov z_losowa1,ax ; ladujemy do losowej liczby dwukrotnosc jej
			
			
			mov ah,2ch 
			int 21h ; Pobieramy czas
			
			xor ax,ax
			mov al,dl
			; UWAGA tutaj zastosowalismy odrazu 50 czyli 2x25 poniewaz dzieki temu mozemy odjac 50 od wylosowanej wiekszej liczby niz 50 i mamy pewnosc ze liczba ta jest wieksza od zera
			cmp dl,50
			jle p4_pomin3; je�li jest mniejsze lub rowne
				; Ten blok wykona sie gdy dl ma wartosc wieksza od 50
				; Odejmiemy wtedy 50 aby miec losowy numer kolumny
				sub al,50
			p4_pomin3:
			mov z_losowa2,ax ; w zmiennej zapisalismy liczbe z zakresu od 0 do 80
			
			
			mov ax,z_losowa1
			mov bx,z_losowa2
			mul bx
			; wynik w ax
			mov si,ax
			
			cmp atr[si],s_kolor_podloza
			jne p4_start ; je�li nie wylosowalismy podloza to skaczemy do gory. B�dziemy tak d�ugo losowac az postawimy owoc na pod�o�u
			
			; malujemy owoc
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_owoc
			
			add z_owocow_na_planszy,1 ; gdy juz postawimy owoc to zwi�kszamy flag� o jeden
		p4_pomin:
		
		ret
	p4__LosujOwoc endp
	
	
	
	
	;=== Procedura wypisujaca liczbe na ekran =======================================================================
	p5__DrukujLiczbe PROC
		ARG liczba:BYTE = PARAMETR
		push bp ; zapisujemy stara wartosc bp na stosie
		mov bp,sp ; do bp ladujemy sp
		xor ax,ax ; czyscimy
		xor cx,cx
		mov cl,10 ; ustawiamy na 10 poniewa� chcemy wy�wietli� wynik w liczbach dziesi�tnych
		mov di,0 ; 
		mov al,liczba
		p5_skok:
		div cl ; AL=(AX div cl), AH=(AX mod cl)
		xor dh,dh
		mov dl,ah
		add dl,30h ; dodajemy 30h aby by�y to liczby ASCII
		push dx ; dx wrzucamy na stos.
		inc di ; zwi�kszamy o jeden
		xor ah,ah
		cmp al,0
		jne p5_skok ; je�li nie jest r�wne 0 to skaczemy do g�ry
		mov cx,di
		p5_skok2:
			pop dx ; zdejmujemy dx ze stosu. B�dziemy go drukowa�
			mov ah,2 ; Funkcja 2 powoduje wypisanie wyniku na standardowe wyj�cie
			int 21h ; przerwanie 21h
		loop p5_skok2
		pop bp ; zdejmujemy wartosc ze stosu i ladujemy do bp
		ret PARAMETR
	p5__DrukujLiczbe ENDP
	
	
	
	

code ends

end start
