include config/pathes

.SILENT: all firmware source update build install uninstall clean cleanall
.PHONY: firmware source build

all:
	./$(DIR_SCRIPTS)/get_source
	./$(DIR_SCRIPTS)/update_source
	./$(DIR_SCRIPTS)/build
	./$(DIR_SCRIPTS)/install
firmware:
	./$(DIR_SCRIPTS)/get_firmware
source:
	./$(DIR_SCRIPTS)/get_source
update:
	./$(DIR_SCRIPTS)/update_source
build:
	./$(DIR_SCRIPTS)/builds
install:
	./$(DIR_SCRIPTS)/install
uninstall:
	./$(DIR_SCRIPTS)/uninstall
clean:
	rm -rf $(DIR_BUILD)
	rm -rf $(DIR_FIRMWARE)
	rm -rf $(DIR_MODULES)
cleanall:
	rm -rf $(DIR_BUILD)
	rm -rf $(DIR_FIRMWARE)
	rm -rf $(DIR_MODULES)
	rm -rf $(DIR_SOURCE)



