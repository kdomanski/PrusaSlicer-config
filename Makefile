VORON_PROFILE_VERSION = 1.0.4
VORON_PROFILE_URL =  https://raw.githubusercontent.com/prusa3d/PrusaSlicer-settings/master/live/Voron/$(VORON_PROFILE_VERSION).ini
VORON_ORIGINAL = Voron-original-$(VORON_PROFILE_VERSION).ini

START_GCODE := '; M190 S0\n; M109 S0 ; uncomment to remove set&wait temp gcode added automatically after this start gcode\nSTART_PRINT EXTRUDER_TEMP={first_layer_temperature[initial_extruder]} BED_TEMP=[first_layer_bed_temperature] CHAMBER=[chamber_temperature] MATERIAL=[filament_type] SIZE={first_layer_print_min[0]}_{first_layer_print_min[1]}_{first_layer_print_max[0]}_{first_layer_print_max[1]}'
END_GCODE := 'END_PRINT    ;end script from macro'
LAYER_GCODE := ';AFTER_LAYER_CHANGE\nSET_PRINT_STATS_INFO CURRENT_LAYER=[layer_num] TOTAL_LAYER=[total_layer_count]'

all: vendor/Voron.ini

clean:
	rm -f Voron-original-*.ini vendor/Voron.ini

.DELETE_ON_ERROR: $(VORON_ORIGINAL)
$(VORON_ORIGINAL):
	curl -L -o $@ $(VORON_PROFILE_URL)

.PHONY: vendor/Voron.ini
.DELETE_ON_ERROR: vendor/Voron.ini
vendor/Voron.ini: $(VORON_ORIGINAL)
	cp $< $@
	./append_opt_in_section.sh '[printer_model:Voron_SW_afterburner]' 'variants' '; volcano 0.4'
	./set_opt_in_section.sh '[printer:*common*]' 'start_gcode' $(START_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'end_gcode' $(END_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'layer_gcode' $(LAYER_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'use_firmware_retraction' 1
	./set_opt_in_section.sh '[printer:*common*]' 'skirts' 0
	./set_opt_in_section.sh '[printer:*common*]' 'default_acceleration' 0
	# ./set_opt_in_section.sh '[printer:*common*]' 'thumbnails_with_bed' 0
	./set_opt_in_section.sh '[filament:*BasicABS*]' 'extrusion_multiplier' '0.95'
	./set_opt_in_section.sh '[filament:*BasicABS*]' 'temperature' '260'
	cat kd_addition.ini >> $@
