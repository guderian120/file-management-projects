#!/bin/bash

# This script encrypts or decrypts files using OpenSSL AES-256-CBC.
# It prompts the user for the operation (encrypt/decrypt), file path, and password.

# Function to show usage instructions
show_usage() {
    echo "Usage: $0"
    echo "This script encrypts or decrypts files using OpenSSL AES-256-CBC."
    echo
    echo "You will be prompted for:"
    echo "  - Operation: encrypt or decrypt"
    echo "  - File path"
    echo "  - Password"
    exit 1
}

# Function to encrypt a file


encrypt_file() {
    local file="$1"
    local password="$2"
    local output="${file}.enc"
    
    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "❌ File '$file' does not exist."
        exit 1
    fi
    
    # Prevent double encryption by checking if file already ends with .enc
    if [[ "$file" == *.enc ]]; then
        echo "⚠️ File '$file' appears to be already encrypted (ends with .enc)."
        echo "Aborting to prevent double encryption."
        exit 1
    fi
    # Encrypt the file using openssl
    # -aes-256-cbc: AES encryption with 256-bit key in CBC mode
    # -salt: adds a random salt to the encryption
    # -pbkdf2: modern key derivation function
    # -in: input file
    # -out: output file
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$file" -out "$output" -k "$password"
    echo "✅ File encrypted as: $output"
}




# Function to decrypt a file
decrypt_file() {
    local file="$1"
    local password="$2"
    local output="${file%.enc}"
    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "❌ File '$file' does not exist."
        exit 1
    fi
    # Check if the file is encrypted
    if [[ "$file" != *.enc ]]; then
        echo "❌ File '$file' does not appear to be an encrypted (.enc) file."
        exit 1
    fi
    # Decrypt the file using openssl and save errors to a variable
    # -d: decrypt
    # -pbkdf2: modern key derivation function (MUST match encryption)
    error=$(openssl enc -aes-256-cbc -pbkdf2 -d -in "$file" -out "$output" -k "$password" 2>&1)
    if [[ $? -ne 0 ]]; then
        if [[ "$error" == *"bad decrypt"* ]]; then
            echo "[ERROR] Bad decrypt: Possibly wrong password."
        else
            echo "[ERROR] Decryption failed: $error"
        fi
        return 1
    else
        echo "Decryption successful. Output saved as $output"
    fi
}

# Prompt the user for input if not provided
read -p "Enter operation (encrypt/decrypt): " mode
read -p "Enter file path: " file
read -s -p "Enter password: " pass
echo

# Convert mode to lowercase for consistency
mode=$(echo "$mode" | tr '[:upper:]' '[:lower:]')

# Run the appropriate function based on the user's choice
case "$mode" in
    encrypt|e)
        encrypt_file "$file" "$pass"
        ;;
    decrypt|d)
        decrypt_file "$file" "$pass"
        ;;
    *)
        echo "❌ Invalid operation: $mode"
        show_usage
        ;;
esac
