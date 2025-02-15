
; r9	; 6th param
; r8	; 5th param
; r10	; 4th param
; rdx	; 3rd param
; rsi	; 2nd param
; rdi	; 1st param
;https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797 Escapes Sequences
ESC = 0x1b
local_mode_offset = 12

FILE_SIZE = 2363

format ELF64 executable 3

segment readable executable

entry $
	mov rdx,clear_screen_size
	lea rsi,[clear_screen]
	call print

	mov rdx,show_cursor_size
	lea rsi,[show_cursor]
	call print

	mov rdx,hide_cursor_size
	lea rsi,[hide_cursor]
	call print

	mov rdx,3
	lea rsi, [move_home]
	call print

	

	;get terminal size
	mov rdi, STDOUT
	mov rsi, TIOCGWINSZ
	lea rdx, [winsize];row [winsize] col [winsize+2]
	call ioctl


	mov rdi, STDIN
	mov rsi, TCGETS
	lea rdx, [termios]
	call ioctl
	cmp rax, 0
	jne ioctl_error


	mov eax, [termios+local_mode_offset]
	mov edx, ICANON
	or edx, ECHO
	not edx
	and eax,edx
	mov [termios+local_mode_offset], eax

	mov rdi, STDIN
	mov rsi, TCSETS
	lea rdx, [termios]
	call ioctl
	cmp rax, 0
	jne ioctl_error

	call print_level	

main_loop:

	mov rdi, STDIN
	lea rsi,[input]
	mov rdx,1
	call read


	cmp [input],'k'
	je move_cursor_up
	cmp [input],'j'
	je move_cursor_down
	cmp [input],'l'
	je move_cursor_right
	cmp [input],'h'
	je move_cursor_left

	cmp [input],'c'
	je debug_show_cursor

	cmp [input],'x'
	je debug_hide_cursor

	cmp [input],'d'
	je move_player_right
	
	cmp [input],'a'
	je move_player_left

	cmp [input],'t'
	je print_level



	jmp main_loop


print_level:
	;call move_cursor_home
	mov rdx,platform_position_size
	lea rsi,[platform_position]
	call print
	mov rdx,platform_size
	lea rsi,[platform]
	call print
	mov rdx,player_position_size
	lea rsi,[player_position]
	call print
	jmp main_loop

move_cursor_home:
	mov rdx,3
	lea rsi,[home_cursor]
	call print
	ret


delete_one_character_left:
	call move_cursor_left
	mov rdx,1
	mov r12,' '
	push r12
	lea rsi,[rsp]
	call print
	pop r12
	ret

delete_one_character_right:
	call move_cursor_left
	mov rdx,1
	mov r12,' '
	push r12
	lea rsi,[rsp]
	call print
	pop r12
	ret

move_player_right:
	call delete_one_character_right	
	mov rdx,1
	lea rsi, [character]
	call print
	jmp main_loop

move_player_left:
	call delete_one_character_left
	call move_cursor_left
	call move_cursor_left

	mov rdx,1
	lea rsi, [character]
	call print
	jmp main_loop

debug_hide_cursor:
	mov rdx,hide_cursor_size	
	lea rsi,[hide_cursor]
	call print
	jmp main_loop

debug_show_cursor:
	mov rdx,show_cursor_size
	lea rsi,[show_cursor]
	call print
	jmp main_loop

;input
move_cursor_up:
	mov rdx, ESCAPE_SIZE
	lea rsi, [cursor_up]
	call print
	jmp main_loop

move_cursor_down:
	mov rdx, ESCAPE_SIZE
	lea rsi, [cursor_down]
	call print
	jmp main_loop

move_cursor_right:
	mov rdx, ESCAPE_SIZE
	lea rsi, [cursor_right]
	call print
	ret

move_cursor_left:
	mov rdx, ESCAPE_SIZE
	lea rsi, [cursor_left]
	call print
	ret

ioctl_error:
	lea rsi, [error_ioctl]	
	mov rdx, error_ioctl_size
	jmp main_loop

open_file_and_print:
	lea rdi, [file_to_open]
	lea rsi, [stat_file]
	call stat
	
	lea rdi, [stat_file+48]
	mov [file_size],FILE_SIZE


	lea rdi,[file_to_open]
	mov rsi, O_RDONLY
	call open
	;cmp rax, EACCES
	;je erro_open

	mov r10,rax;save file descriptor


	;mov rdi,r10
	;mov rsi,0
	;mov rdx,SEEK_END
	;call lseek

	;mov r11,rax ;save file size	
	;mov r11,FILE_SIZE ;save file size	

	mov rdi,0
	call brk
	mov [allocated_memory],rax
	mov rdi,[file_size]
	add rdi,rax
	call brk

	
	;mov rdi, r10
	;call close
	
	;mov rdi,r10
	;mov rsi,0
	;mov rdx,SEEK_SET
	;call lseek

	;lea rdi,[file_to_open]
	;mov rsi, O_RDONLY
	;call open

	;mov r10,rax;save file descriptor

	mov rdi,r10
	lea rsi,[allocated_memory]
	mov rdx,[file_size]
	call read

	
	mov rdi, r10
	call close

	mov rdx,FILE_SIZE
	lea rsi,[allocated_memory]
	call print


	mov rdi,0
	call brk
	mov rdi,[file_size]
	sub rdi,rax
	call brk
	
	;mov rdx,error_open_file_msg_size
	;lea rsi,[error_open_file_msg]
	;call print

	;call print_msg

	call sys_exit
	

erro_open:
	mov edx,error_open_file_msg_size
	lea rsi,[error_open_file_msg]
	call print
	call sys_exit


print_msg:
	mov edx,msg.size
	lea rsi,[msg]
	call print
	ret
	
	

include "syscall.s"

segment readable writeable
;macro for get string size
struc db [data]
     {
       common
        . db data
        .size = $ - .
     }


;movement escapes Sequences
move_home db ESC,'[H'

ESCAPE_SIZE = 4

cursor_mov_buffer db ESC, "[XX"
cursor_up db ESC, "[1A"
cursor_down db ESC, "[1B"
cursor_right db ESC, "[1C"
cursor_left db ESC, "[1D"

character db '#'

msg db 'Message',0xA

error_ioctl db 'ioctl error', 0xA
error_ioctl_size = $-error_ioctl

error_open_file_msg db 'Cant open file',0xA
error_open_file_msg_size = $-error_open_file_msg

file_to_open db 'syscall.s',0

allocated_memory dq ?

clear_screen: db ESC, "[2J"
clear_screen_size = $ - clear_screen

show_cursor: db ESC, "[?25h"
show_cursor_size = $ - show_cursor

hide_cursor: db ESC, "[?25l"
hide_cursor_size = $ - hide_cursor

platform db "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
platform_size = $ - platform


platform_position db ESC,"[9;0H"
platform_position_size = $ - platform_position

player_position db ESC,"[8;0H"
player_position_size = $ - player_position

home_cursor db ESC,"[H"

input_char_buffer rb 1

input rb 1

termios rd 4;c_iflag input mode flags 4 bytes each
						;c_oflag output mode flags
						;c_cflag control mode flags
						;c_lflag local mode flags
				rb 1;c_line line discipline
				rb 19	; c_cc control characters 19 bytes

winsize rw 4;store terminal size

stat_file rb 144;offset size 48

file_size rq 1
