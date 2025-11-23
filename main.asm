INCLUDE Irvine32.inc

.data
; Player boards (10x10 grids for 4 players)
player_boards BYTE 400 DUP(0); 0=water,1=ship,2=hit,3=miss
display_boards BYTE 400 DUP(0);For opponent view
    
; Game state variables
current_player BYTE 1
target_player BYTE 2
game_over BYTE 0
ships_remaining BYTE 5,5,5,5;Ships left for each player

;Ship sizes:Carrier,Battleship,Cruiser,Submarine,Destroyer
ship_sizes BYTE 5,4,3,3,2
   
;Board display characters
water_char BYTE '~'
ship_char BYTE 'S'  
hit_char BYTE 'X'
miss_char BYTE 'O'
unknown_char BYTE '.'
    
; Menu and general messages
welcome_msg BYTE "4-Player Battleship Game",0Dh,0Ah,0
menu_title BYTE "<----- MAIN MENU ----->",0Dh,0Ah,0
menu_option1 BYTE "1.New Game",0Dh,0Ah,0
menu_option2 BYTE "2.How to Play",0Dh,0Ah,0
menu_option3 BYTE "3.Credits",0Dh,0Ah,0
menu_option4 BYTE "4.Exit",0Dh,0Ah,0
menu_prompt BYTE "Enter your choice[1-4]:",0
invalid_choice_msg BYTE "Invalid entry,Kindly select options from 1-4.",0Dh,0Ah,0
    
; How to Play messages
how_to_play_title BYTE "<----- HOW TO PLAY ----->",0Dh,0Ah,0Dh,0Ah,0
how_to_play1 BYTE "Game Rules:",0Dh,0Ah,0
how_to_play2 BYTE ">4 players take turns on the same computer",0Dh,0Ah,0
how_to_play3 BYTE ">Each player has 5 ships of different sizes",0Dh,0Ah,0
how_to_play4 BYTE ">Ships: Carrier(5), Battleship(4), Cruiser(3),",0Dh,0Ah,0
how_to_play5 BYTE ">Submarine(3), Destroyer(2)",0Dh,0Ah,0
how_to_play6 BYTE ">Players attack in sequence: 1->2, 2->3, 3->4, 4->1",0Dh,0Ah,0
how_to_play7 BYTE ">Enter coordinates like 'A5' to attack",0Dh,0Ah,0
how_to_play8 BYTE ">'X'=Hit'O'=Miss,'.'=Unknown",0Dh,0Ah,0
how_to_play9 BYTE ">The last player with ships remaining WINS",0Dh,0Ah,0Dh,0Ah,0
    
; Credits messages
credits_title BYTE "<----- CREDITS ----->",0Dh,0Ah,0Dh,0Ah,0
credits1 BYTE "4-Player Battleship Game",0Dh,0Ah,0
credits2 BYTE "Developed in MASM x86 Assembly",0Dh,0Ah,0
credits3 BYTE "Using Irvine32 Library",0Dh,0Ah,0
credits4 BYTE "Created for COAL Project",0Dh,0Ah,0Dh,0Ah,0
credits5 BYTE "Features:",0Dh,0Ah,0
credits6 BYTE ">4-player pass-and-play gameplay",0Dh,0Ah,0
credits7 BYTE ">Random ship placement",0Dh,0Ah,0
credits8 BYTE ">Graphical board display",0Dh,0Ah,0
credits9 BYTE ">Complete Battleship rules",0Dh,0Ah,0
credits10 BYTE ">Members:",0Dh,0Ah,0
credits11 BYTE ">>Syed Ashar Tahir(24K-0582)",0Dh,0Ah,0
credits12 BYTE ">>Ahmed Nadir Shah(24K-0609)",0Dh,0Ah,0
credits13 BYTE ">>Bilal Ahmed Khan(24K-0777)",0Dh,0Ah,0

; Game messages
player_turn_msg BYTE "<----- PLAYER----->",0
turn_suffix BYTE "'S TURN =",0Dh,0Ah,0
input_prompt BYTE "Enter target coordinates (i.e->A5):",0
hit_msg BYTE "*** Ship HIT! ***",0Dh,0Ah,0
miss_msg BYTE "MISS!",0Dh,0Ah,0
win_msg BYTE "***PLAYER ",0
win_suffix BYTE "WINS!***",0Dh,0Ah,0
invalid_msg BYTE "Invalid entry,Try again.",0Dh,0Ah,0
setup_msg BYTE "Setting up Player",0
setup_suffix BYTE " (Random Placement)...",0Dh,0Ah,0
target_board_msg BYTE "TARGET BOARD (Player ",0
target_board_suffix BYTE "):",0Dh,0Ah,0
your_board_msg BYTE "YOUR BOARD:",0Dh,0Ah,0
ships_left_msg BYTE "Enemy ships remaining: ",0
press_enter_msg BYTE "Press ENTER to continue...",0
pass_computer_msg BYTE "Pass the computer to Player ",0
game_start_msg BYTE "Starting new game...",0Dh,0Ah,0
returning_menu_msg BYTE "Returning to main menu...",0Dh,0Ah,0
    
; Temporary variables
temp_row BYTE 0
temp_col BYTE 0
temp_orientation BYTE 0
current_ship_size BYTE 0
menu_choice BYTE 0

.code
main PROC
call Randomize
call MainMenu
exit
main ENDP

MainMenu PROC
MenuLoop:
call ClearScreen
call DisplayMenu
    
; Get menu choice
mov edx, OFFSET menu_prompt
call WriteString
call ReadInt
    
; Validate and process choice
cmp eax,1
je StartGame
cmp eax,2
je ShowHowToPlay
cmp eax,3
je ShowCredits
cmp eax,4
je ExitGame
    
; Invalid choice
mov edx,OFFSET invalid_choice_msg
call WriteString
mov eax,1500
call Delay
jmp MenuLoop

StartGame:
call ClearScreen
mov edx,OFFSET game_start_msg
call WriteString
mov eax,1000
call Delay
call SetupGame
call GameLoop
call DisplayWinner
jmp MenuLoop

ShowHowToPlay:
call ClearScreen
mov edx,OFFSET how_to_play_title
call WriteString
mov edx,OFFSET how_to_play1
call WriteString
mov edx,OFFSET how_to_play2
call WriteString
mov edx, OFFSET how_to_play3
call WriteString
mov edx,OFFSET how_to_play4
call WriteString
mov edx,OFFSET how_to_play5
call WriteString
mov edx,OFFSET how_to_play6
call WriteString
mov edx,OFFSET how_to_play7
call WriteString
mov edx,OFFSET how_to_play8
call WriteString
mov edx,OFFSET how_to_play9
call WriteString
mov edx,OFFSET press_enter_msg
call WriteString
call ReadChar
jmp MenuLoop

ShowCredits:
call ClearScreen
mov edx,OFFSET credits_title
call WriteString
mov edx,OFFSET credits1
call WriteString
mov edx,OFFSET credits2
call WriteString
mov edx,OFFSET credits3
call WriteString
mov edx,OFFSET credits4
call WriteString
mov edx,OFFSET credits5
call WriteString
mov edx,OFFSET credits6
call WriteString
mov edx,OFFSET credits7
call WriteString
mov edx,OFFSET credits8
call WriteString
mov edx,OFFSET credits9
call WriteString
mov edx,OFFSET credits10
call WriteString
mov edx,OFFSET credits11
call WriteString
mov edx,OFFSET credits12
call WriteString
mov edx,OFFSET credits13
call WriteString
mov edx,OFFSET press_enter_msg
call WriteString
call ReadChar
jmp MenuLoop

ExitGame:
call ClearScreen
mov edx,OFFSET welcome_msg
call WriteString
mov edx,OFFSET returning_menu_msg
call WriteString
mov eax,1000
call Delay
ret
MainMenu ENDP

DisplayMenu PROC
mov edx,OFFSET welcome_msg
call WriteString
call Crlf
mov edx,OFFSET menu_title
call WriteString
mov edx,OFFSET menu_option1
call WriteString
mov edx,OFFSET menu_option2
call WriteString
mov edx,OFFSET menu_option3
call WriteString
mov edx,OFFSET menu_option4
call WriteString
call Crlf
ret
DisplayMenu ENDP

DisplayWelcome PROC
mov edx,OFFSET welcome_msg
call WriteString
call Crlf
ret
DisplayWelcome ENDP

SetupGame PROC
mov ecx,4;4 players
mov esi,0;Player index(0-3)
    
SetupLoop:
push ecx
push esi
    
call ClearScreen
call DisplaySetupMessage
call PlaceShipsForPlayer
    
pop esi
pop ecx
inc esi
loop SetupLoop
ret
SetupGame ENDP

DisplaySetupMessage PROC
mov edx,OFFSET setup_msg
call WriteString
    
mov eax,esi
inc eax
add al,'0'
call WriteChar
    
mov edx,OFFSET setup_suffix
call WriteString
ret
DisplaySetupMessage ENDP

PlaceShipsForPlayer PROC
;ESI=player number (0-3)
mov edi,0; Ship index (0-4)
    
ShipPlaceLoop:
push esi
push edi
call PlaceSingleShip
pop edi
pop esi
inc edi
cmp edi,5
jl ShipPlaceLoop
    
; Show placement complete
call ClearScreen
call DisplaySetupMessage
mov edx,OFFSET press_enter_msg
call WriteString
call ReadChar
ret
PlaceShipsForPlayer ENDP

PlaceSingleShip PROC
;ESI=player, EDI = ship index
mov ecx,50; Max 50 placement attempts
    
TryPlacement:
push ecx
    
; Get random position
mov eax,10
call RandomRange; Random row (0-9)
mov temp_row,al
    
mov eax, 10
call RandomRange; Random column (0-9)
mov temp_col, al
    
; Get random orientation (0=horizontal, 1=vertical)
mov eax,2
call RandomRange
mov temp_orientation,al
    
; Get ship size
mov al,ship_sizes[edi]
mov current_ship_size,al
    
; Validate and place
call ValidateAndPlaceShip
jc PlacementFailed
    
pop ecx
ret

PlacementFailed:
pop ecx
loop TryPlacement
    
;If we get here,force placement at a valid position
call ForcePlaceShip
ret
PlaceSingleShip ENDP

ValidateAndPlaceShip PROC
;Check if ship fits on board
cmp temp_orientation,0
je CheckHorizontal
jmp CheckVertical

CheckHorizontal:
;Check if ship extends beyond right edge
mov al,temp_col
add al,current_ship_size
dec al
cmp al,9
jg InvalidPlacement
jmp CheckCollisions

CheckVertical:
;Check if ship extends beyond bottom edge
mov al,temp_row
add al,current_ship_size
dec al
cmp al,9
jg InvalidPlacement

CheckCollisions:
call CheckShipCollision
jc InvalidPlacement
    
; Place the ship
call PlaceShipOnBoard
clc
ret

InvalidPlacement:
stc
ret
ValidateAndPlaceShip ENDP

CheckShipCollision PROC
push esi
push edi
push edx
push ebx
push ecx
push eax
    
movzx edx,temp_row;Start row
movzx ebx,temp_col;Start column
mov cl,current_ship_size
    
CheckLoop:
;Calculate position
mov eax,esi;Player index
imul eax,100;Player offset
mov edi,edx;Row
imul edi,10; Row offset
add eax,edi
add eax,ebx; Add column
    
;Check bounds
cmp edx,10
jge Collision
cmp ebx,10
jge Collision
    
;Check if occupied
mov edi,OFFSET player_boards
cmp BYTE PTR [edi + eax],0
jne Collision
    
;Move to next position
cmp temp_orientation, 0
je MoveHorz
inc edx
jmp Continue
MoveHorz:
inc ebx
    
Continue:
dec cl
jnz CheckLoop
    
; No collision
pop eax
pop ecx
pop ebx
pop edx
pop edi
pop esi
clc
ret
    
Collision:
pop eax
pop ecx
pop ebx
pop edx
pop edi
pop esi
stc
ret
CheckShipCollision ENDP

PlaceShipOnBoard PROC
push esi
push edi
push edx
push ebx
push ecx
push eax
    
movzx edx,temp_row; Start row
movzx ebx,temp_col; Start column
mov cl,current_ship_size
    
PlaceLoop:
;Calculate position
mov eax,esi; Player index
imul eax,100; Player offset
mov edi,edx; Row
imul edi,10; Row offset
add eax,edi
add eax,ebx; Add column
    
;Place ship
mov edi,OFFSET player_boards
mov BYTE PTR [edi + eax],1
    
; Move to next position
cmp temp_orientation,0
je PlaceHorz
inc edx
jmp PlaceContinue
PlaceHorz:
inc ebx
    
PlaceContinue:
dec cl
jnz PlaceLoop
    
pop eax
pop ecx
pop ebx
pop edx
pop edi
pop esi
ret
PlaceShipOnBoard ENDP

ForcePlaceShip PROC
;Force placement by trying systematic positions
mov ecx,0; Row counter
    
RowLoop:
mov edx,0; Column counter
    
ColLoop:
mov temp_row,cl
mov temp_col,dl
    
;Try both orientations
mov temp_orientation,0 ; Horizontal
call ValidateAndPlaceShip
jc TryVertical
    
;Horizontal worked
ret
    
TryVertical:
mov temp_orientation,1; Vertical
call ValidateAndPlaceShip
jc NextPosition
    
;Vertical worked
ret
    
NextPosition:
inc edx
cmp edx,10
jl ColLoop
    
inc ecx
cmp ecx,10
jl RowLoop
    
;If all else fails,Just place at 0,0
mov temp_row,0
mov temp_col,0
mov temp_orientation,0
call PlaceShipOnBoard
ret
ForcePlaceShip ENDP

GameLoop PROC
MainGameLoop:
cmp game_over,1
je EndGameLoop
    
call PlayerTurnPhase
    
call CheckWinCondition
call SwitchPlayer
    
jmp MainGameLoop
    
EndGameLoop:
ret
GameLoop ENDP

PlayerTurnPhase PROC
;Clear screen and prompt for player change
call ClearScreen
mov edx,OFFSET pass_computer_msg
call WriteString
mov al,current_player
add al,'0'
call WriteChar
call Crlf
mov edx,OFFSET press_enter_msg
call WriteString
call ReadChar
    
;Show game state and get input
call ClearScreen
call DisplayGameState
call GetPlayerInput
call ProcessAttack
    
;Show result and wait
mov edx,OFFSET press_enter_msg
call WriteString
call ReadChar
ret
PlayerTurnPhase ENDP

DisplayGameState PROC
;Display header
mov edx, OFFSET player_turn_msg
call WriteString
mov al,current_player
add al,'0'
call WriteChar
mov edx,OFFSET turn_suffix
call WriteString
call Crlf
    
;Display target info
mov edx,OFFSET target_board_msg
call WriteString
mov al,target_player
add al,'0'
call WriteChar
mov edx,OFFSET target_board_suffix
call WriteString
    
call DisplayTargetBoard
call Crlf
    
;Display player's board
mov edx,OFFSET your_board_msg
call WriteString
call DisplayPlayerBoard
    
;Display ships remaining
mov edx,OFFSET ships_left_msg
call WriteString
mov al,target_player
dec al
movzx esi,al
mov al,ships_remaining[esi]
add al,'0'
call WriteChar
call Crlf
call Crlf
    
ret
DisplayGameState ENDP

DisplayTargetBoard PROC
;Column headers
mov al,' '
call WriteChar
call WriteChar
call WriteChar
mov ecx,10
mov al,'1'
HeaderLoop:
call WriteChar
mov bl,al
mov al,' '
call WriteChar
mov al,bl
inc al
loop HeaderLoop
call Crlf
    
;Board rows
mov ecx,10
mov esi,0
    
RowLoop:
;Row letter
mov al,'A'
add al,cl
dec al
call WriteChar
mov al,' '
call WriteChar
call WriteChar
    
;Cells
mov edi,0
ColLoop:
push ecx
push esi
push edi
    
;Get display board value
mov eax,0
mov al,current_player
dec al
imul eax,100
mov ecx,esi
imul ecx,10
add ecx,edi
mov edx,OFFSET display_boards
add edx,eax
mov al,[edx + ecx]
    
;Display character
cmp al,0
je ShowUnknown
cmp al,1
je ShowMiss
mov al,hit_char
call WriteChar
jmp AfterDisplay
    
ShowUnknown:
mov al,unknown_char
call WriteChar
jmp AfterDisplay
    
ShowMiss:
mov al,miss_char
call WriteChar
    
AfterDisplay:
mov al,' '
call WriteChar
    
pop edi
pop esi
pop ecx
    
inc edi
cmp edi,10
jl ColLoop
    
call Crlf
inc esi
    
;Manual loop for outer loop
dec ecx
jnz RowLoop
    
call Crlf
ret
DisplayTargetBoard ENDP

DisplayPlayerBoard PROC
;Column headers
mov al,' '
call WriteChar
call WriteChar
call WriteChar
mov ecx,10
mov al,'1'
OwnHeaderLoop:
call WriteChar
mov bl,al
mov al,' '
call WriteChar
mov al,bl
inc al
loop OwnHeaderLoop
call Crlf
    
;Board rows
mov ecx,10
mov esi,0
    
OwnRowLoop:
;Row letter
mov al,'A'
add al,cl
dec al
call WriteChar
mov al,' '
call WriteChar
call WriteChar
    
;Cells
mov edi,0
OwnColLoop:
push ecx
push esi
push edi
    
;Get player board value
mov eax,0
mov al,current_player
dec al
imul eax,100
mov ecx,esi
imul ecx,10
add ecx,edi
mov edx,OFFSET player_boards
add edx,eax
mov al,[edx + ecx]
    
; Display character
cmp al,0
je ShowWater
cmp al,1
je ShowShip
cmp al,2
je ShowHit
mov al,miss_char
call WriteChar
jmp AfterOwnDisplay
    
ShowWater:
mov al,water_char
call WriteChar
jmp AfterOwnDisplay
    
ShowShip:
mov al,ship_char
call WriteChar
jmp AfterOwnDisplay
    
ShowHit:
mov al,hit_char
call WriteChar
    
AfterOwnDisplay:
mov al,' '
call WriteChar
    
pop edi
pop esi
pop ecx
    
inc edi
cmp edi,10
jl OwnColLoop
    
call Crlf
inc esi
    
;Manual loop for outer loop
dec ecx
jnz OwnRowLoop
    
call Crlf
ret
DisplayPlayerBoard ENDP

GetPlayerInput PROC
InputLoop:
mov edx, OFFSET input_prompt
call WriteString
    
; Get row
call ReadChar
call WriteChar
cmp al,'A'
jl BadInput
cmp al,'J'
jg BadInput
sub al,'A'
mov bl,al
    
;Get column  
call ReadInt
cmp eax,1
jl BadInput
cmp eax,10
jg BadInput
dec eax
mov bh,al
    
;Check if already attacked
call CheckAlreadyAttacked
jc AlreadyAttacked
    
clc
ret

BadInput:
mov edx,OFFSET invalid_msg
call WriteString
mov eax,1000
call Delay
jmp InputLoop

AlreadyAttacked:
mov edx,OFFSET invalid_msg
call WriteString
mov eax,1000
call Delay
jmp InputLoop
    
GetPlayerInput ENDP

CheckAlreadyAttacked PROC
mov eax,0
mov al,current_player
dec al
imul eax,100
mov ecx,0
mov cl,bl
imul ecx,10
mov edx,0
mov dl,bh
add ecx,edx
mov edx,OFFSET display_boards
add edx,eax
cmp BYTE PTR [edx + ecx],0
je NotAttacked
stc
ret
NotAttacked:
clc
ret
CheckAlreadyAttacked ENDP

ProcessAttack PROC
;BL = row, BH = column
;Calculate target board offset
mov al,target_player
dec al
movzx eax,al
imul eax,100
mov esi,OFFSET player_boards
add esi,eax
    
;Calculate cell offset
movzx eax,bl
imul eax,10
movzx ebx,bh
add eax,ebx
    
;Update display board for current player
push esi
mov esi,OFFSET display_boards
mov eax,0
mov al,current_player
dec al
imul eax,100
add esi,eax
pop edx
    
;Calculate display position
push eax
mov eax,0
mov al,bl
imul eax,10
mov ecx,0
mov cl,bh
add eax,ecx
pop ecx
    
;Check target cell
mov bl,[edx + eax]
cmp bl,1
je HitTarget
    
;Miss
mov BYTE PTR [edx + eax],3
mov BYTE PTR [esi + eax],1
mov edx, OFFSET miss_msg
call WriteString
ret

HitTarget:
mov BYTE PTR [edx + eax],2
mov BYTE PTR [esi + eax],2
mov edx, OFFSET hit_msg
call WriteString
    
;Decrement ship count
mov al,target_player
dec al
movzx ebx,al
dec ships_remaining[ebx]
ret
ProcessAttack ENDP

CheckWinCondition PROC
mov ecx,4
mov esi,0
CheckLoop:
cmp ships_remaining[esi],0
je PlayerWins
inc esi
loop CheckLoop
ret
PlayerWins:
mov game_over,1
ret
CheckWinCondition ENDP

SwitchPlayer PROC
;Move to next player
inc current_player
cmp current_player,5
jl UpdateTarget
mov current_player,1
    
UpdateTarget:
;Target is always next player
mov al,current_player
inc al
cmp al,5
jl SetTarget
mov al,1
SetTarget:
mov target_player,al
ret
SwitchPlayer ENDP

DisplayWinner PROC
call ClearScreen
mov edx,OFFSET win_msg
call WriteString
    
;Find winner
mov ecx,4
mov esi,0
FindWinner:
cmp ships_remaining[esi],0
jg FoundWinner
inc esi
loop FindWinner
ret

FoundWinner:
mov eax,esi
inc eax
add al,'0'
call WriteChar
mov edx,OFFSET win_suffix
call WriteString
call Crlf
    
;Wait before returning to menu
mov edx, OFFSET press_enter_msg
call WriteString
call ReadChar
ret
DisplayWinner ENDP

ClearScreen PROC
call Clrscr
ret
ClearScreen ENDP

END main
