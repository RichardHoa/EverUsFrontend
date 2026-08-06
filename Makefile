.PHONY: all build clean serve stop restart help

FLUTTER_DIR = flutter-project/everus

all:
	$(MAKE) -C $(FLUTTER_DIR) all

build:
	$(MAKE) -C $(FLUTTER_DIR) build

clean:
	$(MAKE) -C $(FLUTTER_DIR) clean

serve:
	$(MAKE) -C $(FLUTTER_DIR) serve

stop:
	$(MAKE) -C $(FLUTTER_DIR) stop

restart:
	$(MAKE) -C $(FLUTTER_DIR) restart

help:
	$(MAKE) -C $(FLUTTER_DIR) help
