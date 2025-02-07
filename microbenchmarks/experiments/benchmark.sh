#!/bin/bash

# How to use:
# ./benchmark.sh <program> <modes> <sparsity/dims> [props]
# Examples:
# ./benchmark.sh ./mb_dynamicTransposeEqualsSquared.dml Std,Gen 4000 sparsity2    

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
elif [[ $SQUARED == "sq2" ]]; then
    VAR_LIST=(1000 2000 3000 4000) 
elif [[ $SQUARED == "sgl" ]]; then
    VAR_LIST=(1)
elif [[ $SQUARED == "sparsity" ]]; then
    VAR_LIST=(0.01 0.001 0.0001)
    VARIATE_SPARSITY=true
elif [[ $SQUARED == "sparsity2" ]]; then
    VAR_LIST=(0.1 0.01 0.001 0.0001)
    VARIATE_SPARSITY=true
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
    # Check if vary sparsity
    if [[ $VARIATE_SPARSITY == true ]]; then
      echo "Running: systemds $PROGRAM -config "$CONFIG" $ADD_ARG -exec singlenode -args $MODE $VAR $SPARSITY"
    OUTPUT=$(systemds "$PROGRAM" -config "$CONFIG" $ADD_ARG -exec singlenode -args "$MODE" "$VAR" $SPARSITY)
    else
      echo "Running: systemds $PROGRAM -config "$CONFIG" $ADD_ARG -exec singlenode -args $MODE $SPARSITY $VAR"
      OUTPUT=$(systemds "$PROGRAM" -config "$CONFIG" $ADD_ARG -exec singlenode -args "$MODE" "$SPARSITY" "$VAR")
    fi

    # Process the output and extract "Result:" lines
    while read -r LINE; do
      if [[ $LINE == Result:* ]]; then
        RESULT=${LINE#Result: }
        ALL_RESULTS+=("$MODE,$VAR,$RESULT")
        echo "Found for MODE=$MODE, VAR=$VAR: $RESULT"
      fi
    done <<< "$OUTPUT"

    # Sleep for 5 seconds to avoid overloading the system
    sleep 5
  done
done


TRIMMED_PROGRAM=$(echo "$PROGRAM" | cut -c 1-$((${#PROGRAM}-4)))

OUTPUT_FILE="resultsMB/"$TRIMMED_PROGRAM"_"$SPARSITY".csv"
# Overwrite the output file:
echo "MODE,VAR,RESULT" > $OUTPUT_FILE

# Print all collected results
echo "All Extracted Results:"
for RES in "${ALL_RESULTS[@]}"; do
  echo "$RES"
  echo "$RES" >> $OUTPUT_FILE
done