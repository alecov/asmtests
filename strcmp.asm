global strcmp_cmps
global strcmp_lods

strcmp_cmps:
.loop:
	cmp byte [rdi], 0
	je .end
	cmpsb
	je .loop
.ret:
	seta ah
	setb al
	sub al, ah
	movsx eax, al
	ret
.end:
	cmpsb
	jmp .ret

strcmp_lods:
.loop:
	lodsb
	mov ah, [rdi]
	test al, al
	jz .end
	inc rdi
	sub ah, al
	jz .loop
.ret:
	movsx eax, ah
	ret
.end:
	sub ah, al
	jmp .ret
