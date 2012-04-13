;###################################################################################################################
;#	Artur Trzop
;#	Snake 2011
;#	The MIT License
;###################################################################################################################
;#	Notacja w kodzie:
;#
;#		pNR__NazwaProcedury
;#			* p - Ka¿da nazwa procedury zaczyna siê od litery p
;#			* NR - oznacza numer procedury
;#			* __ - wymagane dwa podkreœlenia w nazwie procedury
;#			* NazwaProcedury - nazwa naszej procedury
;#
;# 		pNR1_petla_NR2
;#			* pNR1 - numer procedury w której wystêpuje pêtla
;#			* petla - sta³e oznaczenie, ¿e to pêtla
;#			* NR2 - numer pêtli wystêpuj¹cej w procedurze pNR1
;#
;#		petla_Nazwa [S¹ to oznaczenia dla pêtli umieszczonych globalnie]
;#			* petla_ - oznaczenie ze to pêtla
;#			* Nazwa - nazwa dla pêtli
;#
;#		e_pNR1_NR2
;#			* e_ - oznacza, ¿e to etykieta
;#			* pNR1 - numer pêtli w której wystêpuje etykieta
;#			* NR2 - numer etykiety wystêpuj¹cej w pêtli pNR1
;#		
;#		e_Nazwa [S¹ to oznaczenie dla etykiet globalnych]
;#			* e_ - oznaczenie, ¿e to etykieta
;#			* Nazwa - nazwa naszej etykiety
;#
;#		z_Nazwa
;#			* z_ - prefix oznaczaj¹cy zmienn¹
;#			* Nazwa - nazwa naszej zmiennej
;#
;###################################################################################################################

; Stos
stos1 segment STACK
	dw 1024 dup(?) ; podwójne s³owo, dup-duplikat ?-brak okreœlonej wartoœci, pojemnoœæ 1024
	szczyt label word
stos1 ends

dane segment PUBLIC ; PUBLIC - segmenty o tej samej nazwie ³¹czone s¹ w jeden ci¹g³y segment. Wszystkie adresy w segmencie s¹ ³¹czone wzglêdem jego pocz¹tku.
			
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
		
	; D³ugoœc wê¿a. Typ dw czyli s³owo (16 bajtów poniewa¿ mo¿e w¹¿ urosn¹æ do maksymalnie 1794 (ca³a plansza zarysowana. Hipotetyczna sytuacja)) 
	z_dlugosc_weza dw 1  ; Domyœlnie jeden poniewa¿ na pocz¹tku tak¹ d³ugoœæ ma w¹¿
	z_odczekaj dw 0 ; Zmienna przechowujaca czas odczekania
	z_kierunek db 0 ; Kierunek ruchu wê¿a
	; Kody strza³ek: 75-lewo 77-prawo 72-gora 80-dol
	z_lewo db 75d
	z_prawo db 77d
	z_gora db 72d
	z_dol db 80d
	z_esc db 27d
	z_wynik db 0Dh, 0Ah, "KONIEC", 0Dh, 0Ah, "Zdobyles punktow: $"
	z_szybkosc db 4 ; okreœla szybkoœæ wê¿a. Im mniejsza tym szybciej siê w¹¿ porusza
	z_owocow_na_planszy dw 0 ; informuje ile jest owocow na planszy. Gdy bêd¹ 2 to nie bêdziemy dalej losowaæ kolejnych
	z_losowa1 dw 0 ; losowa liczba
	z_losowa2 dw 0
	z_limit_owocow dw 2 ; Ustalamy ile owocow moze byc na planszy jednoczesnie
	
	;=== Sta³e
	s_kolor_ramki equ 14d ; ¿ó³ty kolor dla ramki planszy
	s_kolor_podloza equ 10d ; zielony jasny
	s_kolor_weza equ 15d ; bia³y
	s_kolor_owoc equ 12d ; czerwony	
	s_ascii_podloze equ 176d ; kod ASCII pod³o¿a (trawa)
	s_ascii_waz equ 219d ; kod ASCII kratka zamalowana
	
	
	;=== tablice
	; Tablica bêdzie przechowywa³a po³o¿enie ka¿dego z klocków bêd¹cych czêœci¹ wê¿a. 
	; (80-2)*(25-2)=1796 Maksymalne zarysowanie planszy przez wê¿a. Pomijamy ramki czyli odejmujemy dwa
	; Tablice wype³niamy zerami.
	; Pierwszy element tablicy to g³owa wê¿a, ka¿dy kolejny to 
	s_tab_limit equ 1794d ; Sta³y limit wielkosci tablicy
	tab_waz dw s_tab_limit dup(0) 
	; UWAGA: Opis dzia³ania
	; Tablica bêdzie dzia³aæ jak kolejka. Podczas ruchu wê¿a w miejsce indexu 0 wstawiany bêdzie numer po³o¿enia g³owy wê¿a na ekranie.
	; Dlasze czêœci wê¿a bêd¹ po prostu przesuniête w tablicy o jeden element w górê. Ostatni element bêdzie kasowany przy ka¿dym kolejnym ruchu.
	; Naproœciej mówi¹c przy ka¿dym kolejnym ruchu wê¿a elementy jego po³o¿enia bêd¹ siê przesuwaæ o jeden index w górê.
	; Na index 0 w tablicy wchodzi element do kolejki, a z ostatniego indexu wychodzi element z kolejki.
	; W przypadku gdy w¹¿ zje owoc to nie bêdzie kasowany ostatni element tablicy dziêki czemu w¹¿ uroœnie o jeden element.
	; Do kontrolowania d³ugoœci wê¿a wykorzystamy zmienn¹ pomocnicz¹ z_dlugosc_weza
	; UWAGA##### Tablica typu dw dlatego drugi element jest pod indexem 2. Bêdziemy skakaæ co dwa indexy!!
	
dane ends

; AT - segmenty z tym po³¹czeniem s¹ ³adowane 
; od adresu wskazanego przez wyra¿enie numeryczne
; w naszym przypadku pod adresem 0B8000h znajduje 
; siê pocz¹tek pamiêci ekranu
ekran segment AT 0B800h 
	ek db ?
	atr db ?
ekran ends


; Segment kodu
code segment ; PRIVATE
	
	assume cs:code,ds:dane,es:ekran,ss:stos1
	
	start:
		mov	ax,seg dane ;³adujemy rejestry segmentowe DS i ES
		mov	ds,ax
		mov ax,seg ekran ;pamiêæ ekranu do ES
		mov	es,ax
		;mov	ax,seg code
		mov ax,stos1
		mov ss,ax
		mov sp,offset szczyt
		
		MOV	AH,0 ;wybór trybu pracy monitora
		MOV	AL,3 ;text 80x25 kolor
		INT	10H	;obs³uga ekranu	
		
		
		; Ukrywamy migotaj¹cy kursor
		mov ah, 1
		mov ch, 2bh
		mov cl, 0bh
		int 10h
		
		
		mov	dx,offset z_txt_intro
		mov	ah,9h ; wypisanie tekstu intro	
		int	21h	
		
		call p2__KolorujIntro ; wywo³anie procedury koloruj¹cej napis SNAKE w intro
				
		; Czeka na naciœniêcie dowolnego klawisza
		mov ah, 00h
		int 16h
		
				
		; Rysujemy plansze
		call p1__RysujPlansze
		
		
		
		; Rysujemy wê¿a w pocz¹tkowym miejscu
		mov	ek[2000],219d ; Znak ASCII blok zamalowany 
		mov atr[2000],s_kolor_weza
		
		
		call p4__LosujOwoc
		
		
		
		
		
		;### Naciœniêcie ESC spowoduje wyjœcie z gry
		;### Nacisniêcie strza³ek powoduje start gry
		;### Jeœli naciœniemy inny klawisz to gra czeka a¿ naciœniemy któryœ z wy¿ej wymienionych
		e_UruchomGre:
			mov ah,08h ; Pobiera znak z klawiatury. Bêdzie zapisany w AL
			int 21h ; przerwanie
			
			cmp al,z_esc ; jeœli znak to ESC to wychodzimy z programu
			; Tutaj musilismy wykonaæ trik z stworzeniem pomostu w skoku. Poniewa¿ skok "je" i inne mu podobne s¹ krótkimi skokami
			; Powodowa³o to ¿e nie mo¿na by³o z tego miejsca skoczyæ do koñca programu (relative jump out of range)
			; Dlatego wykonano pomost i u¿yto skoki jmp
			je e_pomost_jmp 
				jmp e_pomin_pomost
			e_pomost_jmp:
			jmp e_KoniecProgramu
			e_pomin_pomost:
			
			; Kody strza³ek: 75-lewo 77-prawo 72-gora 80-dol
			cmp al,z_lewo ; strz³ka w lewo	
			je e_StartWeza
			cmp al,z_prawo ; strz³ka w prawo	
			je e_StartWeza
			cmp al,z_gora ; strz³ka w górê	
			je e_StartWeza
			cmp al,z_dol ; strz³ka w dó³	
			je e_StartWeza
						
			; Jeœli doszliœmy do tego kroku to znaczy ¿e nie przechwycono klawisza ESC ani strza³ek zatem ponownie oczekujemy na naciœniêcie klawisza
			jmp e_UruchomGre 
		
		
		
		;### W¹¿ zaczyna ruch. Ten blok wykona siê tylko przy rozpoczêciu gry
		e_StartWeza:		
			; Jeœli wskoczylismy tu z góry gdzie mamy wybór kierunku ruchu wê¿a przy rozpoczêciu gry to znaczy ¿e w AL mamy wartoœæ strza³ki okreœlaj¹cej 
			; w któr¹ stronê zaczyna ruch w¹¿. Zatem ³adujemy do z_kierunek wartoœæ wybranej strza³ki
			mov z_kierunek,al 
			; Do pierwszego elementu tablicy ³adujemy po³o¿enie pocz¹tkowe naszego wê¿a			
			mov tab_waz[0],2000d ; Jest to po³o¿enie g³owy. G³owa zawsze jest pod indexem 0 w tablicy
						
		
		e_RuchWeza: ; etykieta do której skaczemy gdy w¹¿ jest ju¿ w ruchu
			
			mov di,tab_waz[0] ; di zawiera numer pozycji w ktorej narysowana jest g³owa wê¿a
										
			mov al,z_kierunek ; ³adujemy z_kierunek do AL ¿eby móc wykonac porównanie.
				
			cmp al,z_lewo
			jne e_pomin1 ; Jeœli nie wciœniêto lewo to skaczemy do nastêpnego porównania
				; Ten blok siê wykona jeœli wciœnieto lewo
				sub di,2 ; 
			e_pomin1:
			
			cmp al,z_prawo
			jne e_pomin2
				add di,2
			e_pomin2:
			
			cmp al,z_gora
			jne e_pomin3
				sub di,160 ; odejmujemy 160 aby przesun¹c siê o jeden wiersz w górê
			e_pomin3:
			
			cmp al,z_dol
			jne e_pomin4
				add di,160 ; dodajemy 160 aby przesun¹c siê o jeden wiersz w dó³
			e_pomin4:
			
			
			push di
			push ax
			push cx
			
			; wywo³ujemy procedure która sprawdzi czy w¹¿ wjecha³ na niedozwolony element ramke planszy
			; lub jeœli wjecha³ na owoc to powoduje to wydluzenie wê¿a
			call p3__SprawdzZdarzenie
			
			; wywo³ujemy procedure losujaca owoc
			call p4__LosujOwoc
			
			pop cx
			pop ax
			pop di
			
			
		
		e_PobierzKlawisz:
			mov ah,01h ; Sprawdzamy czy naciœniêto klawisz
			int 16h
			jz e_NieWybranoKlawisza ; Skok jeœli liczba równa zero, czyli jeœli nie naciœniêto ¿adnego klawisza

			mov ah,00h
			int 16h

			cmp al,z_esc ; Porównujemy do klawisza ESC 
			je e_KoniecProgramu ; Jeœli naciœniêto ESC to skaczemy do wyjœcia z gry 
			
			; Jeœli naciœniêto klawisze 1,2,3 to zmieniamy szybkoœæ wê¿a
			cmp al,31h
			je e_szyb_1				
			cmp al,32h
			je e_szyb_2			
			cmp al,33h
			je e_szyb_3
			
			; Jeœli naciœniêto 4 to zwiekszamy limit owocow na planszy o jeden
			; jeœli 5 to zwiekszamy limit o 5
			; jeœli naciœniêto 6 to resetujemy limit owocow na 2
			cmp al,34h ;4 - zwiekszamy limit owocow o 1
			je e_limit_owocow1				
			cmp al,35h ;5 - zwiekszamy limit owocow o 5
			je e_limit_owocow2	
			cmp al,36h ;6 - resetujemy limit owocow na 2
			je e_limit_owocow3
			
			
			mov z_kierunek,ah ; ³adujemy numer naciœniêtego klawisza do zmiennej informuj¹cej o kierunku ruchu
			jmp e_NieWybranoKlawisza ; skaczemy do etykiety aby pominac ustawienia szybkosci jesli nie skoczono do nich wczesniej
			
			
			; Obs³uga zmiany szybkosci ruchu wê¿a
			e_szyb_1:
				mov z_szybkosc,4 ; wolno
				jmp e_NieWybranoKlawisza
			e_szyb_2:
				mov z_szybkosc,2 ; œrednia prêdkoœæ
				jmp e_NieWybranoKlawisza
			e_szyb_3:
				mov z_szybkosc,1 ; szybko
				jmp e_NieWybranoKlawisza
				
				
			; Obs³uga zmiany limitu owocow na planszy
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



		; OpóŸnienie. Cykl 18,2 na sekundê
		mov ah,00h
		int 1ah
		cmp dx,z_odczekaj
		jb e_PobierzKlawisz ; jb - skok gdy jest poni¿ej (CF=1)
		xor cx,cx
		mov cl,z_szybkosc ; Dziêki tej zmiennej bêdziemy mogli zmieniaæ sobie szybkoœæ wê¿a
		add dx,cx
		mov z_odczekaj,dx
		
		
		jmp e_RuchWeza ; Powtarzamy ruch wê¿a skacz¹c do etykiety e_RuchWeza
		
		
		
	
		
		
		;mov	dx,offset tekst1
		;mov	ah,9h ; wypisanie tekstu (DOS)		
		;int	21h	; funkcja DOS
			
		;int 16h ; Wymaga naciœniêcia dowolnego klawisza aby przejœæ dalej
		
		e_KoniecProgramu:	
			mov	ax,4c00h;koniec programu (DOS)
			int	21h
	





	;###################################################################################################################
	;### Procedury
	;### ASCII http://www.asciitable.com/

	;=== Rysowanie obramowania planszy =================================================================================
	p1__RysujPlansze proc
		
		;=== Ustawiamy limit ekranu, limit ile razy siê pêtla wykona
		mov	cx,80*25
		
		
		;=== Rysujemy t³o planszy które bêdzie pod³o¿em (trawa). T³o to bêdzie póŸniej zamalowane przez ramki planszy
		mov	si,0
		p1_petla_1:	
			mov	ek[si],s_ascii_podloze ; kod ASCII dla kropeczek, które bêd¹ udawac trawê
			mov atr[si],s_kolor_podloza ; zielony jasny
			add si,2 ; zwiêkszamy index o dwa
		loop p1_petla_1
		
		
		
		;=== Rysujemy górn¹ i doln¹ linie obramowania planszy				
		mov	si,0 ; zaczynamy rysowanie od indexu zero
		p1_petla_2:

			; rysowanie górnej poziomej linii
			cmp si,160d
			jge e_p1_1 ; jeœli rysujemy ju¿ powy¿ej 80 znaku to pomijamy rysowanie (jeœli si jest wiêksze lub równe 160 (dlatego równe bo rysujemy od 0))
				mov	ek[si],219d ; Znak ASCII blok zamalowany 				
				mov atr[si], s_kolor_ramki ; ³adujemy ¿ó³ty kolor
			e_p1_1:
			
			; rysowanie poziomej linii na dole ekranu
			cmp si,3840d ; 2*80*25 = 2*2000 = 4000  (od 4000 odj¹c jedn¹ linijkê tekstu 80*2 czyli 4000-160=3840)
			jnge e_p1_2 ; skok gdy nie jest wiêkszy od
				mov	ek[si],219d ; Znak ASCII blok zamalowany 
				mov atr[si],s_kolor_ramki ; ³adujemy ¿ó³ty kolor
			e_p1_2:
						
			add si,2 ; zwiêkszamy index o dwa poniwa¿ 1-to znak ASCII a 2-to atrybut
		loop p1_petla_2
		
		
		
		;=== Rysujemy linie ponow¹ z lewej strony
		; 23 poniewa¿ bêdziemy rysowaæ pionow¹ linie z pominiêciem ju¿ narysowanego jednego znaku u góry i do³u ekranu
		mov	cx,23 ; limit wywo³ania pêtli.
		mov si,160
		p1_petla_3:
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_ramki ; ³adujemy ¿ó³ty kolor			
			add si,160 ; przesuwamy siê o jeden ca³y wiersz
		loop p1_petla_3
		
		
		
		;=== Rysujemy linie ponow¹ z prawej strony
		; 23 poniewa¿ bêdziemy rysowaæ pionow¹ linie z pominiêciem ju¿ narysowanego jednego znaku u góry i do³u ekranu
		mov	cx,23 ; limit wywo³ania pêtli.
		mov si,318 ; zaczynamy rysowanie od 318 czyli od drugiego wiersza i ostatniego znaku w nim. (160 + 158)
		p1_petla_4:
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_ramki ; ³adujemy ¿ó³ty kolor			
			add si,160 ; przesuwamy siê o jeden ca³y wiersz
		loop p1_petla_4
		
		

		ret ; Powrót 
	p1__RysujPlansze endp





	;=== Rysowanie obramowania planszy =================================================================================
	p2__KolorujIntro proc

		mov	cx,80*8 ; limit wywo³ania pêtli. Ustawiamy na 8 bo chcemy ustawic kolor dla osmiu wierszy (ka¿dy wiersz to 80 znaków czyli 160 bo mamy atrybut)
		mov si,5*160 ; zaczynamy rysowanie od 5 wiersza bo tam zaczyna siê napis SNAKE
		mov al,1d ; ³adujemy kolor do AL
		p2_petla_1:
			
			; Kolor wiersza 0 jest ustawiony powy¿ej w AL. Pierwsza linia znaków która rysuje duzy napis SNAKE
			
			cmp si,6*160
			je e_p2_kolor_wiersza_1 ; jeœli si równe 6*160 to mo¿emy zmieniæ kolor przechowywany w al
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
			
		
			; Przeskakujemy ustawienia kolorów. Jeœli powy¿ej nie nast¹pi³ skok do zmiany koloru w rejestrze AL to pomijamy zmiane kolorów 
			; skacz¹c do e_p2_1 i u¿ywaj¹c koloru aktualnie przechowywanego w rejestrze AL.
			; Dziêki takiemu zabiegowi nie bêdziemy ustawiaæ rejestru AL na ten sam kolor przy ka¿dym ponowym ustawianiu atrybutu danego znaku na ekranie
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
				mov atr[si],al ; ³adujemy ¿ó³ty kolor			
				add si,2 ; przesuwamy siê o dwa czyli o jedn¹ literkê
			
		loop p2_petla_1
		
		ret ; Powrót
	p2__KolorujIntro endp
	
	
	
	
	
	
	;=== Funkcja sprawdzaj¹ca czy dotkniêto œciany lub owocu =======================================================================
	; Jeœli dotkniêto owocu to nastêpuje wyd³u¿enie wê¿a.
	; Funkcja ponadto obs³uguje ruch wê¿a i zapis jego po³o¿enia w kolejce opartej o tablicê tab_waz
	p3__SprawdzZdarzenie proc

		; W di zapisany jest numer w którym postawiona bêdzie g³owa wê¿a. Sprawdzimy czy uderzy o œcianê
		
		cmp atr[di],s_kolor_ramki
		jne p3_pomin1 ; jeœli kolor klocka na który wstawiæ chcemy wê¿a nie jest koloru ramki to przeskakujemy
			jmp p3_uderzono_w_przeszkode ; jesli wjechalismy na	ramke
		p3_pomin1:
		cmp atr[di],s_kolor_weza 
		jne p3_pomin2 ; jeœli kolor klocka na który wstawiæ chcemy wê¿a nie jest koloru wê¿a to przeskakujemy
			jmp p3_uderzono_w_przeszkode
		
		
		p3_uderzono_w_przeszkode:
			mov	dx,offset z_wynik
			mov	ah,9h ; wypisanie tekstu o koñcu gry.	
			int	21h	
			
			xor ax,ax
			mov ax,z_dlugosc_weza ; ³adujemy do ax dlugosc weza
			push ax ; wk³adamy na stos ax
			call p5__DrukujLiczbe ; wywo³ujemy procedure wypisujaca wynik liczbowy
			
			
			; Czeka na naciœniêcie dowolnego klawisza
			mov ah, 00h
			int 16h
			
			jmp e_KoniecProgramu
			
			
		p3_pomin2:
		
		; Tutaj napisac sprawdzanie najechania na owoc. Ma to spowodowac ze nie wywola sie kasowanie ogona
		xor bx,bx
		; w bl bêdziemy przechowywac informacje czy nast¹pi³o zjedzenie owoca. 
		; Jeœli tak to inna bêdzie wywo³ywana pêtla.
		; 0-oznacza ze nie zwiekszono dlugosci weza		
		mov bl,0 
		
		cmp atr[di],s_kolor_owoc
		jne p3_pomin3 ; jeœli nie stawiamy g³owy wê¿a na owocu to skaczemy do etykiety
			; Ten blok wykona siê gdy postawiliœmy g³owê wê¿a na owocu
			; Dodajemy zwiêkszamy wiêc d³ugoœæ wê¿a
			add z_dlugosc_weza,1
			mov bl,1 ; ustawiamy flagê z informacj¹ ¿e zwiêkszono d³ugoœæ wê¿a bo zjedzono owoc			
			
		p3_pomin3:
			
			
			;############
			; Gdy w¹¿ d³u¿szy ni¿ 1 i nie zwiêkszono jego d³ugoœci
			cmp z_dlugosc_weza,1
			jle e_pomin_war1_; skok gdy jest mniejszy lub rowny 1
				jmp e_pomin_war1_blok
			e_pomin_war1_: ; pomost aby wykonac dlugi skok
				jmp e_pomin_war1
				e_pomin_war1_blok:
				; Ten blok siê wykona gdy w¹¿ ma d³ugoœæ wiêksz¹ od 1
				cmp bl,0
				jne e_pomin_war2 ; skocz gdy bl nie jest rowne 0
					;###### Ten blok wykona siê gdy bl=0 czyli gdy nie zjedzono owocu
					; Przenosimy elementy w tablicy o jeden index w górê, a w miejsce indexu=0 wstawimy now¹ g³owê wê¿a
					xor cx,cx ; czyœcimy cx
					; ile razy ma siê wykonaæ pêtla. Jest to iloœæ operacji przeniesienia elementów w tablicy która jest nasz¹ kolejk¹
					; Dlatego -1 bo nie przenosimy ostatniego elementu nigdzie dalej gdyz ma byc on nadpisany przez przedostatni element
					mov cx,z_dlugosc_weza
					sub cx,1
					
					; si bêdziemy zmniejszaæ co krok
					; -4 poniewaz ostatni element tablicy nie bedzie przenoszony poniewaz jest on kasowany jesli nie najechano na owoc. A minus 4 poniewa¿ tablica zaczyna siê od indexu 0 i skaczemy co dwa indexy aby dostac sie do kolejnego elementu
					mov si,z_dlugosc_weza
					add si,z_dlugosc_weza ; dwukrotna dlugosc zapisujemy poniewaz idziemy po tablicy co 2 indexy
					sub si,4

					; Kasowanie ostatniego elementu z planszy
					; odbywa siê przed operacj¹ przeniesienia elementów w tablicy o jeden index w górê
					; poniewa¿ w czasie przeniesienia tych elementow przedostatni element przykrywa ostatni i nie mielibysmy pozniej mozliwosci odczytania jakie polozenie ma ogon weza
					push di
					xor di,di
					mov di,tab_waz[si+2] ; +2 poniewaz wyzej mielismy -4 i to bylo wybranie przedostatniego elementu a my potrzebujemy ostatni element w tablicy
					mov	ek[di],s_ascii_podloze ; Znak ASCII pod³o¿a planszy
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
					;###### Ten blok wykona siê gdy bl=1 czyli gdy zjedzono owoc
					
					sub z_owocow_na_planszy,1 ; zjedlismy owoc wiec odejmujemy z licznika
					
					; Przenosimy elementy w tablicy o jeden index w górê, a w miejsce indexu=0 wstawimy now¹ g³owê wê¿a
					xor cx,cx ; czyœcimy cx
					; ile razy ma siê wykonaæ pêtla. Jest to iloœæ operacji przeniesienia elementów w tablicy która jest nasz¹ kolejk¹
					; Dlatego -1 bo nie przenosimy ostatniego elementu nigdzie dalej gdyz ma byc on nadpisany przez przedostatni element
					mov cx,z_dlugosc_weza
					sub cx,1
					
					; si bêdziemy zmniejszaæ co krok
					; -4 poniewaz ostatni element tablicy nie bedzie przenoszony poniewaz jest on kasowany jesli nie najechano na owoc. A minus 4 poniewa¿ tablica zaczyna siê od indexu 0
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
			; Poni¿szy kod wykonuje siê gdy w¹¿ ma d³ugoœæ 1
			cmp z_dlugosc_weza,1
			jne e_pomin_a ; jeœli nie jest rowne 1
				; Ten blok wykona siê gdy w¹¿ ma d³ugoœæ 1
				push di ; odkladamy di na stos
				mov di,tab_waz[0] ; pobieramy numer pozycji starego polozenia glowy weza
				; wstawiamy podloze w miejsce starego polozenia glowy
				mov	ek[di],s_ascii_podloze ; Znak ASCII pod³o¿a planszy
				mov atr[di],s_kolor_podloza
				pop di ; zdejmujemy ze stosu di, ktory nam wskazuje nowe polozenie g³owy wê¿a
				mov tab_waz[0],di ; zapisujemy glowe weza w tablicy
				jmp e_pomin_b			
			
			e_pomin_a:
				; do pierwszego elementu tablicy ³adujemy nowe po³o¿enie glowy weza
				mov tab_waz[0],di
				
			e_pomin_b:
			
			; Rysujemy g³owe wê¿a
			mov	ek[di],s_ascii_waz ; Znak ASCII
			mov atr[di],s_kolor_weza
		
	
		ret
	p3__SprawdzZdarzenie endp
	
	
	
	
	
	
	
	
	;=== Funkcja losuj¹ca po³o¿enie owoca na planszy =======================================================================
	; Jeœli wylosowane pole jest ju¿ zajête to ponawiamy losowanie az trafimy 
	; na puste pole czyli na podloze na ktorym bedziemy mogli postawic owoc
	p4__LosujOwoc proc
		
		mov si,z_limit_owocow
		cmp z_owocow_na_planszy,si
		jge p4_pomin ; jeœli na planszy jest wiecej owocow lub tyle samo ile wynosi limit to pomijamy generowanie kolejnych owocow
		
		p4_start: ; rozpoczynamy losowanie owoca
			
			mov ah,2ch 
			int 21h ; Pobieramy czas
			; CH=godziny CL=minuty DH=sekundy DL=1/100s
			
			xor ax,ax
			mov al,dl
			; UWAGA tutaj losujemy tylko do 80 poniewaz dl moze max przyjac wartosc 100.
			; Pozniej sobie zwiekszymy dwukrotnie ta wartosc
			cmp dl,80
			jle p4_pomin2; jeœli jest mniejsze lub rowne
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
			jle p4_pomin3; jeœli jest mniejsze lub rowne
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
			jne p4_start ; jeœli nie wylosowalismy podloza to skaczemy do gory. Bêdziemy tak d³ugo losowac az postawimy owoc na pod³o¿u
			
			; malujemy owoc
			mov	ek[si],219d ; Znak ASCII blok zamalowany 
			mov atr[si],s_kolor_owoc
			
			add z_owocow_na_planszy,1 ; gdy juz postawimy owoc to zwiêkszamy flagê o jeden
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
		mov cl,10 ; ustawiamy na 10 poniewa¿ chcemy wyœwietliæ wynik w liczbach dziesiêtnych
		mov di,0 ; 
		mov al,liczba
		p5_skok:
		div cl ; AL=(AX div cl), AH=(AX mod cl)
		xor dh,dh
		mov dl,ah
		add dl,30h ; dodajemy 30h aby by³y to liczby ASCII
		push dx ; dx wrzucamy na stos.
		inc di ; zwiêkszamy o jeden
		xor ah,ah
		cmp al,0
		jne p5_skok ; jeœli nie jest równe 0 to skaczemy do góry
		mov cx,di
		p5_skok2:
			pop dx ; zdejmujemy dx ze stosu. Bêdziemy go drukowaæ
			mov ah,2 ; Funkcja 2 powoduje wypisanie wyniku na standardowe wyjœcie
			int 21h ; przerwanie 21h
		loop p5_skok2
		pop bp ; zdejmujemy wartosc ze stosu i ladujemy do bp
		ret PARAMETR
	p5__DrukujLiczbe ENDP
	
	
	
	

code ends

end start
