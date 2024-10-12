import os
import logging
from multiprocessing import Pool, cpu_count, Manager
from functools import partial
from rich.progress import Progress
from rich.console import Console
from rich.traceback import install
from rich.logging import RichHandler
from file_utils import get_sol_files
from sol_lex import tokenize_solidity_file

# Install Rich traceback handler for better exception display
install(show_locals=True)

# Set up Rich logging
logging.basicConfig(
    level=logging.INFO, format="%(message)s", datefmt="[%X]", handlers=[RichHandler()]
)
log = logging.getLogger("rich")

console = Console()

def process_file(sol_file, dataset_dir, output_dir, progress_queue):
    try:
        # Get relative path from dataset_dir and construct output path
        rel_path = os.path.relpath(sol_file, dataset_dir)
        output_file = os.path.join(output_dir, f"{rel_path}.tokens")

        # Ensure the output directory exists
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

        # Write tokens to file as they are generated
        with open(output_file, 'w', encoding='utf-8') as f:
            for token in tokenize_solidity_file(sol_file):
                f.write(f"{token}\n")

        # Notify progress
        progress_queue.put(1)

    except Exception as e:
        log.exception(f"Error processing file {sol_file}")

def process_file_batch(sol_file, dataset_dir, output_dir, progress_queue):
    try:
        process_file(sol_file, dataset_dir, output_dir, progress_queue)
    except Exception as e:
        log.exception(f"Error processing file {sol_file}")

def update_progress(progress, task_id, total_files, progress_queue):
    processed_files = 0
    while processed_files < total_files:
        # Wait for a signal from the worker processes
        progress_queue.get()
        processed_files += 1
        progress.update(task_id, completed=processed_files)
    progress.stop()

def main():
    dataset_dir = 'datast'
    output_dir = 'out_tokens'

    try:
        sol_files = get_sol_files(dataset_dir)

        if not sol_files:
            console.print("[red]No Solidity files found in the dataset directory.")
            return

        num_cores = min(cpu_count(), 2)  # Limit to 2 cores
        console.print(f"[green]Using {num_cores} CPU cores for processing.")

        total_files = len(sol_files)

        with Manager() as manager:
            progress_queue = manager.Queue()

            # Set up the progress bar
            progress = Progress(console=console)
            task_id = progress.add_task("[green]Processing Solidity files...", total=total_files)
            progress.start()

            # Start the progress updater thread
            from threading import Thread
            progress_thread = Thread(target=update_progress, args=(progress, task_id, total_files, progress_queue))
            progress_thread.start()

            # Divide files into batches
            batch_size = 100  # Adjust as needed
            file_batches = [sol_files[i:i + batch_size] for i in range(0, len(sol_files), batch_size)]

            for batch in file_batches:
                process_func = partial(process_file_batch, dataset_dir=dataset_dir, output_dir=output_dir, progress_queue=progress_queue)

                with Pool(processes=num_cores) as pool:
                    pool.map(process_func, batch)

            progress_thread.join()

            console.print("[bold green]Processing completed successfully!")

    except Exception as e:
        log.exception("An unexpected error occurred during processing.")

if __name__ == "__main__":
    main()
