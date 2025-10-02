.PHONY: all clean

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	rm -f .*.cmd* .*.o* *.cmd* *.o* *.mod* *.ko *.order *.symvers*
