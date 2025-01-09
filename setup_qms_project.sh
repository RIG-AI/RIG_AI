#!/bin/bash

# Create directories
mkdir -p qms_project/{config,utils,core,data,tests}

# Create files with content

# main.py
cat << 'EOF' > qms_project/main.py
from config.settings import load_settings
from core.qms_algorithm import run_qms
from utils.result_formatter import format_results
import json

def main():
    # Load settings
    settings = load_settings()

    # Example input data
    hashed_server_seed = settings['hashed_server_seed']
    client_seed = settings['client_seed']
    losing_columns = settings['losing_columns']

    # Run the QMS algorithm
    predictions = run_qms(hashed_server_seed, client_seed, losing_columns)

    # Format and print results
    formatted_results = format_results(predictions)
    print(formatted_results)

    # Save results to file
    with open("data/predictions.json", "w") as f:
        json.dump(predictions, f, indent=4)

if __name__ == "__main__":
    main()
EOF

# config/settings.py
cat << 'EOF' > qms_project/config/settings.py
import json

def load_settings():
    with open("data/example_inputs.json", "r") as f:
        return json.load(f)
EOF

# config/constants.py
cat << 'EOF' > qms_project/config/constants.py
MAX_ROWS = 9
MAX_COLUMNS = 3
SHIFT_AMOUNT_MULTIPLIER = 20
EOF

# utils/seed_processor.py
cat << 'EOF' > qms_project/utils/seed_processor.py
def process_hashed_seed(hashed_server_seed):
    try:
        return int(hashed_server_seed, 16)
    except ValueError:
        return 0

def process_client_seed(client_seed):
    return sum(ord(char) for char in client_seed)
EOF

# utils/losing_column_parser.py
cat << 'EOF' > qms_project/utils/losing_column_parser.py
def parse_losing_columns(columns):
    try:
        return [int(column) for column in columns]
    except ValueError:
        raise ValueError("Invalid losing column data")
EOF

# utils/confidence_calculator.py
cat << 'EOF' > qms_project/utils/confidence_calculator.py
def calculate_confidence(raw_value):
    return 100 - (raw_value / 2.55)
EOF

# utils/result_formatter.py
cat << 'EOF' > qms_project/utils/result_formatter.py
def format_results(predictions):
    formatted = ["Quantum Markov Synergy Predictions:"]
    for row in predictions:
        formatted.append(f"Row {row['row']} - Safe Columns: {row['cols']}")
        formatted.append(f"  Confidence: {row['confidence']}")
        formatted.append(f"  Combined Confidence: {row['combined_confidence']:.2f}%")
    return "\n".join(formatted)
EOF

# core/qms_algorithm.py
cat << 'EOF' > qms_project/core/qms_algorithm.py
from core.key_folding import fold_keys
from core.column_selector import select_columns

def run_qms(hashed_server_seed, client_seed, losing_columns):
    folded_key = fold_keys(hashed_server_seed, client_seed, losing_columns)
    return select_columns(folded_key)
EOF

# core/key_folding.py
cat << 'EOF' > qms_project/core/key_folding.py
from utils.seed_processor import process_hashed_seed, process_client_seed
from config.constants import MAX_ROWS

def fold_keys(hashed_server_seed, client_seed, losing_columns):
    S = process_hashed_seed(hashed_server_seed)
    C = process_client_seed(client_seed)
    combined = (S ^ C) % (2**256)

    keys = []
    for i, column in enumerate(losing_columns, start=1):
        folded = (combined ^ column) + i
        keys.append(folded % (2**256))
    
    return keys
EOF

# core/confidence_handler.py
cat << 'EOF' > qms_project/core/confidence_handler.py
from utils.confidence_calculator import calculate_confidence
from config.constants import MAX_COLUMNS, SHIFT_AMOUNT_MULTIPLIER

def calculate_confidences(folded_key, row):
    confidences = {}
    for col in range(1, MAX_COLUMNS + 1):
        shift_amount = SHIFT_AMOUNT_MULTIPLIER * (row + col)
        raw_value = (folded_key >> shift_amount) & 0xFF
        confidences[col] = calculate_confidence(raw_value)
    return confidences
EOF

# core/column_selector.py
cat << 'EOF' > qms_project/core/column_selector.py
from core.confidence_handler import calculate_confidences

def select_columns(folded_keys):
    predictions = []
    for row, folded_key in enumerate(folded_keys, start=1):
        confidences = calculate_confidences(folded_key, row)
        sorted_columns = sorted(confidences, key=confidences.get, reverse=True)[:2]
        combined_confidence = sum(confidences[col] for col in sorted_columns) / 2
        predictions.append({
            'row': row,
            'cols': sorted_columns,
            'confidence': confidences,
            'combined_confidence': combined_confidence
        })
    return predictions
EOF

# data/example_inputs.json
cat << 'EOF' > qms_project/data/example_inputs.json
{
  "hashed_server_seed": "4eedddd07ae87af17afcedabb0d1a7f5e30638503a8c350e94dc2ade0aef4d00",
  "client_seed": "GKvAe9oBvMptWSqO",
  "losing_columns": [111332221, 223313321, 132331312, 32231332, 212123333]
}
EOF

# tests/test_qms_algorithm.py
cat << 'EOF' > qms_project/tests/test_qms_algorithm.py
from core.qms_algorithm import run_qms

def test_run_qms():
    hashed_seed = "4eedddd07ae87af17afcedabb0d1a7f5e30638503a8c350e94dc2ade0aef4d00"
    client_seed = "GKvAe9oBvMptWSqO"
    losing_columns = [111332221, 223313321, 132331312]
    predictions = run_qms(hashed_seed, client_seed, losing_columns)
    assert len(predictions) == 3
EOF

# Completion message
echo "Project setup complete!"
