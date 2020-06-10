TOP=..

include $(TOP)/configure/CONFIG

install:
	$(ETHERCAT)/etc/scripts/expandChain.py chain.xml > FE10B.xml
	echo $(ETHERCAT)/bin/linux-x86_64/scanner -q $(PWD)/etc/FE10B.xml /tmp/scanner > scanner.sh
	chmod +x scanner.sh

clean:
	-rm FE10B.xml

uninstall:


