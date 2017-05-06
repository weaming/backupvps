backup:
	@bash backup.sh
	@echo 'backup successfully!'

install:
	@bash backup.sh install
	# show backup file for debug
	bash backup.sh restore $(ls -rt | grep vps.backup)

clean:
	@if [ -d tmp ]; then rm -rf tmp; fi
	@echo 'Done!'

.PHONY: backup install restore clean

