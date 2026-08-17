import pandas as pd
import glob
import os
from cryptography.fernet import Fernet

datasets_folder = os.path.join(os.path.dirname(__file__), '..', '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# =============================================================================
# Step 1: Load first 5 employees and add sample phone numbers
# =============================================================================
# Phone numbers are included in the employee file

df = pd.read_csv(find_file('employee_*.csv')).head(5).copy()

print("=" * 60)
print("ORIGINAL DATA - First 5 Employees with Phone Numbers")
print("=" * 60)
print(df[['emp_id', 'emp_name', 'designation', 'phone_number']].to_string(index=False))

# =============================================================================
# Step 2: Generate an encryption key
# =============================================================================
# Fernet is a symmetric encryption method - same key encrypts and decrypts
# Fernet.generate_key() creates a unique random secret key
# This key must be kept safe - without it, decryption is impossible

print("\n" + "=" * 60)
print("STEP 2: Generating Fernet Encryption Key")
print("=" * 60)

encryption_key = Fernet.generate_key()
cipher = Fernet(encryption_key)

print(f" Encryption key (keep this secret): {encryption_key.decode()}")

# =============================================================================
# Step 3: Encrypt phone numbers
# =============================================================================
# cipher.encrypt() takes bytes input and returns encrypted bytes
# .encode() converts string to bytes before encrypting
# .decode() converts encrypted bytes to a storable string

print("\n" + "=" * 60)
print("STEP 3: Encrypting Phone Numbers")
print("=" * 60)

df['phone_encrypted'] = df['phone_number'].apply(lambda x: cipher.encrypt(str(x).encode()).decode())

print(df[['emp_id', 'emp_name', 'phone_number', 'phone_encrypted']].to_string(index=False))

# =============================================================================
# Step 4: Decrypt phone numbers
# =============================================================================
# cipher.decrypt() reverses the encryption using the same key
# Only someone with the encryption key can decrypt

print("\n" + "=" * 60)
print("STEP 4: Decrypting Phone Numbers")
print("=" * 60)

df['phone_decrypted'] = df['phone_encrypted'].apply(lambda x: cipher.decrypt(x.encode()).decode())

print(df[['emp_id', 'emp_name', 'phone_encrypted', 'phone_decrypted']].to_string(index=False))
