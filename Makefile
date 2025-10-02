KDIR ?= /lib/modules/$(shell uname -r)/build
PWD ?= $(shell pwd)

.PHONY: all clean

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	rm -f .*.cmd* .*.o* *.cmd* *.o* *.mod* *.ko *.order *.symvers*
