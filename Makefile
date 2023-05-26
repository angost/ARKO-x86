EXEFILE = main
OBJECTS = main.o f.o
CCFMT = -m64
NASMFMT = -f elf64
CCOPT =
NASMOPT = -w+all
LDFLAGS = -L/usr/lib -lallegro -L/usr/lib -lallegro_primitives

.c.o:
	cc $(CCFMT) $(CCOPT) -c $<

.s.o:
	nasm $(NASMFMT) $(NASMOPT) -l $*.lst $<

$(EXEFILE): $(OBJECTS)
	cc $(CCFMT) -o $@ $^ $(LDFLAGS)

clean:
	rm *.o *.lst $(EXEFILE)