#!/bin/bash

# e.g. create-test-md.sh agentic_workflow.py server.py templates/index.html
# e.g. create-test-md.sh agentic_workflow.py server.py templates/index.html output.md
# https://poe.com/s/N5vlkEoZNMzlsgUXAujw

# Hardcoded exclude list - add patterns here (supports wildcards)
exclude_list=(
    "__pycache__"
    "node_modules"
    ".git"
    "*.pyc"
    ".DS_Store"
    "test*.*"
)

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file1> <file2> ... [output.md]"
    echo "Example: $0 agentic_workflow.py server.py template/index.html"
    echo "Example: $0 agentic_workflow.py server.py template/index.html output.md"
    exit 1
fi

# Get all arguments into an array
files=("$@")
num_files=$#

# Get the last argument
eval "last_file=\${$num_files}"

# Check if we have more than one file AND the last argument is a .md file
# AND the last file doesn't exist (indicating it's meant to be an output file)
if [[ $num_files -gt 1 && "$last_file" == *.md && ! -f "$last_file" ]]; then
    # Last file is .md and doesn't exist, use it as output file
    output_file="$last_file"
    # Create new array without the last element
    input_files=()
    for ((i=1; i<num_files; i++)); do
        eval "input_files+=(\${$i})"
    done
else
    # Either single file or last file exists or isn't .md - treat all as input files
    output_file="test.md"
    input_files=("$@")
fi

# Check if we have any input files left
if [ ${#input_files[@]} -eq 0 ]; then
    echo "Error: No input files specified"
    echo "Usage: $0 <file1> <file2> ... [output.md]"
    exit 1
fi

# Function to check if a path should be excluded
should_exclude() {
    local path="$1"
    local filename=$(basename "$path")

    for pattern in "${exclude_list[@]}"; do
        # Check if pattern contains wildcards
        if [[ "$pattern" == *"*"* ]] || [[ "$pattern" == *"?"* ]]; then
            # Use bash pattern matching for wildcards
            # Check against both full path and filename
            if [[ "$path" == $pattern ]] || [[ "$filename" == $pattern ]]; then
                return 0  # true - should exclude
            fi
        else
            # Use substring matching for non-wildcard patterns
            if [[ "$path" == *"$pattern"* ]]; then
                return 0  # true - should exclude
            fi
        fi
    done
    return 1  # false - should not exclude
}

# Create output file and start with the initial content
cat > "$output_file" << 'EOF'
PUT_TASK_HERE

EOF

# Track processed files for final message
processed_files=()

# Process each input file
for file in "${input_files[@]}"; do
    # Check if file should be excluded
    if should_exclude "$file"; then
        echo "Skipping excluded file: $file"
        continue
    fi

    # Add to processed files list
    processed_files+=("$file")

    # Extract filename without path for the header
    filename=$(basename "$file")

    # Determine file extension for syntax highlighting
    extension="${filename##*.}"
    case "$extension" in
        py)
            lang="python"
            ;;
        html|htm)
            lang="html"
            ;;
        js)
            lang="javascript"
            ;;
        css)
            lang="css"
            ;;
        sh)
            lang="bash"
            ;;
        json)
            lang="json"
            ;;
        yml|yaml)
            lang="yaml"
            ;;
        md)
            lang="markdown"
            ;;
        *)
            lang=""
            ;;
    esac

    # Write the section header
    echo "# $file" >> "$output_file"
    echo "\`\`\`$lang" >> "$output_file"

    # Read and append the file content
    if [ -f "$file" ]; then
        cat "$file" >> "$output_file"
    else
        echo "[File $file not found]" >> "$output_file"
    fi

    # Close the code block and add spacing
    echo '```' >> "$output_file"
    echo "" >> "$output_file"
done

if [ ${#processed_files[@]} -gt 0 ]; then
    echo "$output_file has been created successfully with content from:"
    for file in "${processed_files[@]}"; do
        echo "  - $file"
    done
else
    echo "No files were processed (all files were excluded)"
fi
