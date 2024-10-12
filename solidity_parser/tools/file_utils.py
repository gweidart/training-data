import os
import logging

log = logging.getLogger("rich")

def get_sol_files(dataset_dir):
    sol_files = []
    try:
        # Loop through contract1 to contract43
        for i in range(1, 44):
            contract_dir = os.path.join(dataset_dir, f"contract{i}")
            if os.path.isdir(contract_dir):
                for file_name in os.listdir(contract_dir):
                    if file_name.endswith('.sol'):
                        full_path = os.path.join(contract_dir, file_name)
                        sol_files.append(full_path)
            else:
                log.warning(f"Directory {contract_dir} does not exist.")
        return sol_files
    except Exception as e:
        log.exception("Error while retrieving Solidity files.")
        raise
