obj-m := mpro.o

KVER ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KVER)/build
INSTALL_MOD_DIR ?= extra

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install: all
	$(MAKE) -C $(KDIR) M=$(PWD) INSTALL_MOD_DIR=$(INSTALL_MOD_DIR) modules_install
	depmod -a $(KVER)

uninstall:
	rm -f /lib/modules/$(KVER)/$(INSTALL_MOD_DIR)/mpro.ko*
	depmod -a $(KVER)

.PHONY: all clean install uninstall
