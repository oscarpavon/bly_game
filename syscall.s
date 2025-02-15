sum:
     mov rax,rdi 
      ret 0

say_hello:
      mov rax,1;;sys write
      mov rdi,1;;stdout file descriptor
      ;;lea rsi,[hello]
      mov rdx,6;;byte lenght
      syscall
      ret 0

;;linux function argument RDI, RSI, RDX, RCX, R10, R8, R9
;;linux syscall sys_read = 0 sys_write = 1 sys_close = 3 sys_open = 2 sys_lseek = 8

;this need to be in rax before "syscall" asm
SYS_READ = 0
SYS_WRITE = 1
SYS_OPEN = 2
SYS_CLOSE = 3
SYS_STAT = 4
SYS_FSTAT = 5
SYS_LSEEK = 8
SYS_BRK = 12
SYS_IOCTL = 16
SYS_SENDFILE = 40
SYS_FORK = 57
SYS_EXECVE = 59
SYS_EXIT = 60
SYS_WAIT4 = 61

;end syscall

;files
SEEK_SET = 0	;Seek from beginning of file
SEEK_CUR = 1	;Seek from current position
SEEK_END = 2	;Seek from end of file

EACCES = 13

O_RDONLY	 =    0000o
O_WRONLY	 =    0001o
O_CREAT	   =    0100o	


;Stat
STAT_STRUCT_SIZE = 144
STAT_MODE = 24
STAT_SIZE = 48
;end files

;proces identification
WNOHANG = 1

;Standard Linux file descriptors
STDIN = 0
STDOUT = 1
STDERR = 2

;ioctl
TCGETS = 0x5401
TCSETS = 0x5402

TIOCGWINSZ = 0x5413 ;terminal size


ICANON = 0000002
ECHO = 0000010 ; Enable echo

;rdi file descriptor
;rsi command IOCTL number
;rdx argument data structure
;out rax 0 success - negative error
ioctl:
      mov rax, SYS_IOCTL
      syscall
      ret


;rdi file descriptors
;rsi memory
;rdx bytes to read
read:
      mov rax,SYS_READ
      syscall
      ret

write:
      mov rax,SYS_WRITE
      syscall
      ret


;rdi pid
;rsi can be 0
;rdx options, can be 0
;r10 can be 0
;out rax pid
wait4:
      mov rax,SYS_WAIT4
      syscall
      ret

;none argument
fork:
      mov rax,SYS_FORK  
      syscall
      ret

;rdi file path
;rsi argument value
;rdx environment pointer
execve:
      mov rax,SYS_EXECVE
      syscall
      ret

;rdi file path
;rsi stat buffer
stat:
      mov rax,SYS_STAT
      syscall
      ret

;rdi file descriptor
;rsi stat buffer
fstat:
      mov rax,SYS_FSTAT
      syscall
      ret

;rdi = file path
;rsi = open mode
;out rax = file descriptor
open:
      mov rax,SYS_OPEN
      syscall
      ret

;rdi = 0 to get brk position / got position - bytes
;out eax = got position / memory position allocated
brk:
      mov rax,SYS_BRK
      syscall
      ret

;rdi file descriptor to close
close:
      mov rax,SYS_CLOSE
      syscall
      ret

;rdi out file descriptor
;rsi in file descriptor
;rdx offset could be 0
;r10 count
sendfile:
      mov rax,SYS_SENDFILE
      syscall
      ret

;rdi file descriptor
;rsi offset
;rdx seek option
;out eax position in bytes
lseek:
      mov rax,SYS_LSEEK
      syscall
      ret

;;end linux syscall

;lea rsi,text
;rdx size
print:
      mov rax,SYS_WRITE
      mov rdi,STDOUT
      syscall
      ret

sys_exit:
      mov rax, SYS_EXIT
      xor rdi,rdi
      syscall
      ret

