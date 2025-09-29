obj-m := untitled.o

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
