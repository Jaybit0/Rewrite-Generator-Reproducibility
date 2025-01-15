#!/bin/bash

BASE_CONFIG=./config/SystemDS-config-base.xml
OPT_CONFIG=./config/SystemDS-config-opt.xml

PROGRAM=$1 
MODE_LIST=$2
# Convert the string to an array by replacing commas with spaces
IFS=',' read -r -a MODES <<< "$MODE_LIST"
SPARSITY=$3          # Replace with your sparsity value
SQUARED=${4:-""}

# If squared is "sq", then
if [[ $SQUARED == "sq" ]]; then
    echo "Squared"
    VAR_LIST=(1000 5000 10000)  # Replace with your list of integers
elif [[ $SQUARED == "sgl" ]]; then
    VAR_LIST=(1)
else
    VAR_LIST=(1000000 5000000 10000000)  # Replace with your list of integers
fi

# Initialize an array to store all results
ALL_RESULTS=()

# Loop through each mode
for MODE in "${MODES[@]}"; do
  echo "Processing mode: $MODE"

  # Base optlevel is only if MODE=Base
    if [[ $MODE == *"Base"* ]]; then
        CONFIG=$BASE_CONFIG
    else
        CONFIG=$OPT_CONFIG
    fi

    # If MODE contains GEN, then we add an additional argument
    if [[ $MODE == *"Gen"* ]]; then
        ADD_ARG="-applyGeneratedRewrites"
    else 
        ADD_ARG=""
    fi

  # Loop through the list of integers and run the program
  for VAR in "${VAR_LIST[@]}"; do
    echo "Running: systemds $PROGRAM -config "$CONFIG" $ADD_ARG -exec singlenode -args $MODE $SPARSITY $VAR"
    OUTPUT=$(systemds "$PROGRAM" -config "$CONFIG" $ADD_ARG -exec singlenode -args "$MODE" "$SPARSITY" "$VAR")

    # Process the output and extract "Result:" lines
    while read -r LINE; do
      if [[ $LINE == Result:* ]]; then
        RESULT=${LINE#Result: }
        ALL_RESULTS+=("$MODE,$VAR,$RESULT")
        echo "Found for MODE=$MODE, VAR=$VAR: $RESULT"
      fi
    done <<< "$OUTPUT"

    # Sleep for 1 second to avoid overloading the system
    sleep 3
  done
done

echo $PROGRAM
MP="$PROGRAM"
TRIMMED_PROGRAM=$(echo "$PROGRAM" | cut -c 1-$((${#PROGRAM}-4)))
echo $TRIMMED_PROGRAM
OUTPUT_FILE="resultsMB/"$TRIMMED_PROGRAM"_"$SPARSITY".csv"
# Overwrite the output file:
echo "MODE,VAR,RESULT" > $OUTPUT_FILE

# Print all collected results
echo "All Extracted Results:"
for RES in "${ALL_RESULTS[@]}"; do
  echo "$RES"
  echo "$RES" >> $OUTPUT_FILE
done