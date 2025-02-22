VORON_PROFILE_VERSION = 2.0.0
VORON_PROFILE_URL =  https://raw.githubusercontent.com/prusa3d/PrusaSlicer-settings-non-prusa-fff/main/Voron/$(VORON_PROFILE_VERSION).ini
VORON_ORIGINAL = Voron-original-$(VORON_PROFILE_VERSION).ini

START_GCODE := '; M190 S0\n; M109 S0 ; uncomment to remove set&wait temp gcode added automatically after this start gcode\nSTART_PRINT EXTRUDER_TEMP={first_layer_temperature[initial_extruder]} BED_TEMP=[first_layer_bed_temperature] MATERIAL=[filament_type] SIZE={first_layer_print_min[0]}_{first_layer_print_min[1]}_{first_layer_print_max[0]}_{first_layer_print_max[1]}\n\n;PrusaSlicer has no chamber tempterature setting\n;CHAMBER=|chamber_temperature|'
END_GCODE := 'END_PRINT    ;end script from macro'
LAYER_GCODE := ';AFTER_LAYER_CHANGE\nSET_PRINT_STATS_INFO CURRENT_LAYER=[layer_num] TOTAL_LAYER=[total_layer_count]'

all: vendor/Voron.ini update_prusaslicer_ini

clean:
	rm -f Voron-original-*.ini vendor/Voron.ini

# implicit rule for templated ini files
%.ini : %.ini.tmpl
	gomplate < $< > $@

.DELETE_ON_ERROR: $(VORON_ORIGINAL)
$(VORON_ORIGINAL):
	curl -L -o $@ $(VORON_PROFILE_URL)
	sed 's/\r//' -i $@

.PHONY: vendor/Voron.ini
.DELETE_ON_ERROR: vendor/Voron.ini
vendor/Voron.ini: $(VORON_ORIGINAL) kd_addition.ini
	cp $< $@
	./append_opt_in_section.sh '[printer_model:Voron_v2_300_afterburner]' 'variants' '; volcano 0.4'
	./set_opt_in_section.sh '[printer:*common*]' 'start_gcode' $(START_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'end_gcode' $(END_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'layer_gcode' $(LAYER_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'use_firmware_retraction' 1
	./set_opt_in_section.sh '[printer:*common*]' 'skirts' 0
	./set_opt_in_section.sh '[printer:*common*]' 'default_acceleration' 0
	./set_opt_in_section.sh '[printer:*common*]' 'travel_acceleration' 0
	./set_opt_in_section.sh '[printer:*common*]' 'travel_speed' 400
	# ./set_opt_in_section.sh '[printer:*common*]' 'thumbnails_with_bed' 0
	./set_opt_in_section.sh '[filament:*BasicABS*]' 'extrusion_multiplier' '0.95'
	./set_opt_in_section.sh '[filament:*BasicABS*]' 'temperature' '260'
	./set_opt_in_section.sh '[print:*common*]' 'gcode_label_objects' 'firmware'
	cat kd_addition.ini >> $@

.PHONY: update_prusaslicer_ini
update_prusaslicer_ini: PrusaSlicer.ini
	FILE="PrusaSlicer.ini" ./set_opt_in_section.sh '[vendor:Voron]' 'model:Voron_v0_120' '0.4'
	FILE="PrusaSlicer.ini" ./set_opt_in_section.sh '[vendor:Voron]' 'model:Voron_v2_300_afterburner' '"volcano 0.4";"volcano 0.6";"volcano 0.8"'
