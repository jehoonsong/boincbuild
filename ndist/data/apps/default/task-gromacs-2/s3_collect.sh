#!/bin/bash

# Set base directories
PROJECT_ROOT="/home/boincadm/project"
HELLO_DIR="/data/task"
cd $HELLO_DIR || exit 1

# Output directory (same as HELLO_DIR)
OUT_DIR="$HELLO_DIR"
echo "[INFO] Working in directory: $HELLO_DIR"

# Loop through all *_wu marker files
for wu_file in *_wu; do
	echo "[INFO] Processing: $wu_file"

	# Extract workunit name from the file
	wu_name=$(grep "workunit name:" "$wu_file" | awk '{print $3}')
	if [ -z "$wu_name" ]; then
		echo "[WARN] No workunit name found in: $wu_file"
		continue
	fi

	# Search for the result file under the upload directory
	result_path=$(find "$PROJECT_ROOT/upload" -name "${wu_name}_*")
	if [ -z "$result_path" ]; then
		echo "[WARN] Result not found for: $wu_name"
		continue
	fi

	# Extract an index or suffix from the input filename
	index=$(echo "$wu_file" | sed -n 's/.*-\([0-9]\+\)\.tgz_wu/\1/p')
	out_file="${OUT_DIR}/out-$(basename "$wu_file" .tgz_wu).tgz"

	# Copy the result file to the designated output
	cp "$result_path" "$out_file"
	echo "[INFO] Result copied to → $out_file"
done

echo "[DONE] All workunits processed."
