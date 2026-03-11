#!/bin/bash

# Usage:
#   bash demo_run.sh [DEVICE_OR_CUDA_INDEX] [INPUT_PATH]
# Examples:
#   bash demo_run.sh auto data/examples/office
#   bash demo_run.sh mps data/examples/office
#   bash demo_run.sh 0 /path/to/your/data

# Get arguments
DEVICE_ARG=${1:-auto}
INPUT_PATH=$2

if [[ "$DEVICE_ARG" =~ ^[0-9]+$ ]]; then
    export CUDA_VISIBLE_DEVICES=$DEVICE_ARG
    DEVICE=auto
else
    DEVICE=$DEVICE_ARG
fi

if [ "$(uname -s)" = "Darwin" ]; then
    export XFORMERS_DISABLED=1
fi

# choose from LoGeR, LoGeR_star
ckpt_list=( 
    "LoGeR"
    "LoGeR_star"
)

for ckpt_name in "${ckpt_list[@]}"; do
    echo "--- Processing checkpoint: $ckpt_name ---"
    config_path="ckpts/${ckpt_name}/original_config.yaml"
    model_path="ckpts/${ckpt_name}/latest.pt"

    input_path="${INPUT_PATH:-data/examples/office}"

    echo "Running evaluation..."

    uv run python demo_viser.py \
        --input "$input_path" \
        --config "$config_path" \
        --model_name "$model_path" \
        --device "$DEVICE" \
        --start_frame 0 \
        --end_frame 50 \
        --stride 1 \
        --window_size 32 \
        --overlap_size 3 \
        --subsample 2 \
        --share
        # --reset_every 5  # turned on for extreme long sequences (>1k frames)


    echo "--- Finished processing $ckpt_name ---"
    echo ""
done

echo "All checkpoints have been processed."
